const supabaseAdmin = require("../config/supabaseAdmin");

const HardwareIssueModel = {
  async getDeviceMapping(deviceId) {
    const { data, error } = await supabaseAdmin
      .from("device_compartment_mapping")
      .select("*")
      .eq("device_id", deviceId)
      .maybeSingle();
    if (error) throw error;
    return data;
  },

  async getOpenIssue(deviceId) {
    const { data, error } = await supabaseAdmin
      .from("hardware_issues")
      .select("*")
      .eq("device_id", deviceId)
      .eq("status", "open")
      .order("id", { ascending: false })
      .limit(1)
      .maybeSingle();
    if (error) throw error;
    return data;
  },

  async recordIssue(deviceId, issueType) {
    const mapping = await this.getDeviceMapping(deviceId);
    if (!mapping) {
      const err = new Error("Unknown device_id, no compartment mapping found");
      err.code = "UNKNOWN_DEVICE";
      throw err;
    }

    const open = await this.getOpenIssue(deviceId);
    if (open) {
      const err = new Error("Compartment already has an open issue");
      err.code = "OPEN_EXISTS";
      err.existing = open;
      throw err;
    }

    const now = new Date().toISOString();
    const { data, error } = await supabaseAdmin
      .from("hardware_issues")
      .insert({
        device_id: deviceId,
        train_no: mapping.train_no,
        coach_no: mapping.coach_no,
        compartment_no: mapping.compartment_no,
        issue_type: issueType,
        status: "open",
        opened_at: now,
        created_at: now,
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  async resetIssue(deviceId) {
    const open = await this.getOpenIssue(deviceId);
    if (!open) return null;

    const closedAt = new Date();
    const responseSeconds = Math.max(
      1,
      Math.round((closedAt.getTime() - new Date(open.opened_at).getTime()) / 1000)
    );

    const { data, error } = await supabaseAdmin
      .from("hardware_issues")
      .update({
        status: "closed",
        closed_at: closedAt.toISOString(),
        response_seconds: responseSeconds,
      })
      .eq("id", open.id)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  async getAll({ status, coachNo, trainNo, compartmentNo, deviceId, dateFrom, dateTo, limit = 200 } = {}) {
    try {
      let query = supabaseAdmin
        .from("hardware_issues")
        .select("*")
        .order("id", { ascending: false });

      if (status) query = query.eq("status", status);
      if (coachNo) query = query.eq("coach_no", coachNo);
      if (trainNo) query = query.eq("train_no", trainNo);
      if (compartmentNo) query = query.eq("compartment_no", compartmentNo);
      if (deviceId) query = query.eq("device_id", deviceId);
      if (dateFrom) query = query.gte("opened_at", dateFrom);
      if (dateTo) query = query.lte("opened_at", dateTo);

      const { data, error } = await query;
      if (error) throw error;
      return data || [];
    } catch (err) {
      console.error("HardwareIssue Model getAll error:", err.message);
      throw err;
    }
  },

  async getReportSummary({ dateFrom, dateTo, trainNo, coachNo, compartmentNo, deviceId } = {}) {
    let query = supabaseAdmin
      .from("hardware_issues")
      .select("*")
      .order("opened_at", { ascending: false });

    if (dateFrom) query = query.gte("opened_at", dateFrom);
    if (dateTo) query = query.lte("opened_at", dateTo);
    if (trainNo) query = query.eq("train_no", trainNo);
    if (coachNo) query = query.eq("coach_no", coachNo);
    if (compartmentNo) query = query.eq("compartment_no", compartmentNo);
    if (deviceId) query = query.eq("device_id", deviceId);

    const { data, error } = await query;
    if (error) {
      console.error("HardwareIssue Model getReportSummary error:", error.message);
      throw error;
    }

    const rows = data || [];

    const totalCount = rows.length;
    const openCount = rows.filter(r => r.status === "open").length;
    const closedCount = rows.filter(r => r.status === "closed").length;

    const byType = {
      linen: { count: 0, responseSeconds: 0 },
      cleaning: { count: 0, responseSeconds: 0 },
    };
    const byDay = {};
    const peakHours = Array.from({ length: 24 }, (_, h) => ({
      hour: h,
      count: 0,
      resolved: 0,
      responseSeconds: 0,
      responseCount: 0,
    }));

    rows.forEach(r => {
      const type = r.issue_type || "unknown";
      if (!byType[type]) byType[type] = { count: 0, responseSeconds: 0 };
      byType[type].count++;

      if (r.opened_at) {
        const d = new Date(r.opened_at);
        const day = r.opened_at.slice(0, 10);
        if (!byDay[day]) byDay[day] = { date: day, linen: 0, cleaning: 0, total: 0 };
        byDay[day].total++;
        byDay[day][type] = (byDay[day][type] || 0) + 1;

        peakHours[d.getHours()].count++;
      }

      if (r.status === "closed" && r.closed_at) {
        const res = peakHours[new Date(r.closed_at).getHours()];
        res.resolved++;
        if (r.response_seconds) {
          res.responseSeconds += r.response_seconds;
          res.responseCount++;
        }
      }

      if (r.status === "closed" && r.response_seconds) {
        if (!byType[type].responseSeconds) byType[type].responseSeconds = 0;
        byType[type].responseSeconds += r.response_seconds;
      }
    });

    const resolvedPerHour = peakHours.map(h => ({
      hour: h.hour,
      resolved: h.resolved,
      avgResponseSeconds:
        h.responseCount > 0 ? Math.round(h.responseSeconds / h.responseCount) : null,
    }));

    const totalResponseSeconds = Object.values(byType).reduce(
      (sum, t) => sum + t.responseSeconds, 0
    );
    const totalClosed = closedCount;

    const avgResponseSeconds =
      totalClosed > 0 ? Math.round(totalResponseSeconds / totalClosed) : null;

    const shareByType = {};
    if (totalCount > 0) {
      shareByType.linen = Math.round(((byType.linen?.count || 0) / totalCount) * 100);
      shareByType.cleaning = Math.round(((byType.cleaning?.count || 0) / totalCount) * 100);
    }

    return {
      totalCount,
      openCount,
      closedCount,
      linenCount: byType.linen?.count || 0,
      cleaningCount: byType.cleaning?.count || 0,
      avgResponseSeconds,
      shareByType,
      byDay: Object.values(byDay).sort((a, b) => a.date.localeCompare(b.date)),
      peakHours,
      resolvedPerHour,
      requests: rows.slice(0, 200),
    };
  },
};

module.exports = HardwareIssueModel;