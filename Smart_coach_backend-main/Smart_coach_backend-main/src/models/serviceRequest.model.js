const supabaseAdmin = require("../config/supabaseAdmin");

const ServiceRequestModel = {
    async create(data) {
        try {
            const { data: result, error } = await supabaseAdmin
                .from("service_requests")
                .insert({
                    train_no: data.train_no,
                    coach_no: data.coach_no,
                    seat_berth: data.seat_berth,
                    service_type: data.service_type,
                    description: data.description || null,
                    passenger_name: data.passenger_name || null,
                    passenger_phone: data.passenger_phone || null,
                    status: "pending"
                })
                .select()
                .single();

            if (error) throw error;
            return result;
        } catch (err) {
            console.error("ServiceRequest Model create error:", err.message);
            throw err;
        }
    },

    async getAll({ status, limit = 50, offset = 0, dateFrom, dateTo } = {}) {
        try {
            let query = supabaseAdmin
                .from("service_requests")
                .select("*", { count: "exact" });

            if (status) {
                query = query.eq("status", status);
            }
            if (dateFrom) {
                query = query.gte("created_at", dateFrom);
            }
            if (dateTo) {
                query = query.lte("created_at", dateTo);
            }

            query = query.order("created_at", { ascending: false });

            if (limit) query = query.limit(limit);
            if (offset) query = query.range(offset, offset + limit - 1);

            const { data, error, count } = await query;
            if (error) throw error;
            return { data: data || [], count };
        } catch (err) {
            console.error("ServiceRequest Model getAll error:", err.message);
            throw err;
        }
    },

    async getById(id) {
        try {
            const { data, error } = await supabaseAdmin
                .from("service_requests")
                .select("*")
                .eq("id", id)
                .single();

            if (error) throw error;
            return data;
        } catch (err) {
            console.error("ServiceRequest Model getById error:", err.message);
            throw err;
        }
    },

    async updateStatus(id, status, updatedBy, resolutionNotes) {
        try {
            const updateData = {
                status: status,
                updated_at: new Date().toISOString()
            };

            if (status === "resolved") {
                updateData.resolved_by = updatedBy || null;
                updateData.resolved_at = new Date().toISOString();
                updateData.resolution_notes = resolutionNotes || null;
            }

            const { data, error } = await supabaseAdmin
                .from("service_requests")
                .update(updateData)
                .eq("id", id)
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (err) {
            console.error("ServiceRequest Model updateStatus error:", err.message);
            throw err;
        }
    },

    async getReportSummary({ dateFrom, dateTo } = {}) {
        try {
            let query = supabaseAdmin
                .from("service_requests")
                .select("*");

            if (dateFrom) {
                query = query.gte("created_at", dateFrom);
            }
            if (dateTo) {
                query = query.lte("created_at", dateTo);
            }

            query = query.order("created_at", { ascending: false });

            const { data, error } = await query;
            if (error) throw error;

            const rows = data || [];

            const totalCount = rows.length;
            const pendingCount = rows.filter(r => r.status === "pending").length;
            const inProgressCount = rows.filter(r => r.status === "in_progress").length;
            const resolvedCount = rows.filter(r => r.status === "resolved").length;

            const byServiceType = {};
            rows.forEach(r => {
                const key = r.service_type || "unknown";
                byServiceType[key] = (byServiceType[key] || 0) + 1;
            });

            const byDay = {};
            rows.forEach(r => {
                const day = (r.created_at || "").slice(0, 10);
                if (day) {
                    if (!byDay[day]) byDay[day] = { total: 0, pending: 0, resolved: 0 };
                    byDay[day].total++;
                    if (r.status === "pending") byDay[day].pending++;
                    if (r.status === "resolved") byDay[day].resolved++;
                }
            });

            const avgResolutionTime = (() => {
                const resolved = rows.filter(r => r.resolved_at && r.created_at);
                if (resolved.length === 0) return null;
                const totalMs = resolved.reduce((sum, r) => {
                    return sum + (new Date(r.resolved_at) - new Date(r.created_at));
                }, 0);
                return Math.round(totalMs / resolved.length / (1000 * 60 * 60) * 10) / 10;
            })();

            return {
                totalCount,
                pendingCount,
                inProgressCount,
                resolvedCount,
                byServiceType,
                byDay,
                avgResolutionHours: avgResolutionTime,
                requests: rows
            };
        } catch (err) {
            console.error("ServiceRequest Model getReportSummary error:", err.message);
            throw err;
        }
    }
};

module.exports = ServiceRequestModel;
