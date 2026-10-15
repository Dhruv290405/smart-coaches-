const BaseModel = require("./base.model");
const supabaseAdmin = require("../config/supabaseAdmin");

class CoachModel extends BaseModel {
  constructor() {
    super("coaches");
  }

  async createCoach(data) {
    const created_date = new Date().toISOString();

    const { data: existingCoach } = await supabaseAdmin
      .from("coach_master")
      .select("coach_id")
      .eq("coach_unique_id", data.coach_unique_id)
      .maybeSingle();

    if (existingCoach) {
      throw new Error(`Coach with unique ID "${data.coach_unique_id}" already exists.`);
    }

    const { data: coachData, error: coachError } = await supabaseAdmin
      .from("coach_master")
      .insert([{
        entity_type: data.entity_type,
        coach_unique_id: data.coach_unique_id,
        coach_display_id: data.coach_display_id,
        make_of_coach: data.make_of_coach,
        type_of_coach: data.type_of_coach,
        manufacturing_year: data.manufacturing_year,
        no_of_master_module: data.no_of_master_module,
        coach_status: data.coach_status,
        created_by: data.created_by,
        created_date: created_date
      }])
      .select();

    if (coachError) throw new Error("Failed to create coach: " + coachError.message);

    return coachData[0].coach_id;
  }

  async updateCoach(data) {
    const { data: duplicateCoach } = await supabaseAdmin
      .from("coach_master")
      .select("coach_id")
      .eq("coach_unique_id", data.coach_unique_id)
      .neq("coach_id", data.coach_id)
      .maybeSingle();

    if (duplicateCoach) {
      throw new Error(`Coach Unique ID "${data.coach_unique_id}" is already used by another coach.`);
    }

    const { error: updError } = await supabaseAdmin
      .from("coach_master")
      .update({
        entity_type: data.entity_type,
        coach_unique_id: data.coach_unique_id,
        coach_display_id: data.coach_display_id,
        make_of_coach: data.make_of_coach,
        type_of_coach: data.type_of_coach,
        manufacturing_year: data.manufacturing_year,
        position: data.position,
        no_of_master_module: data.no_of_master_module,
        coach_status: data.coach_status,
        updated_by: data.updated_by
      })
      .eq("coach_id", data.coach_id);
    if (updError) throw new Error("Failed to update coach: " + updError.message);

    return true;
  }

  async deleteCoach(coach_id) {
    const { error: nullError } = await supabaseAdmin
      .from("master_module")
      .update({ coach_id: null })
      .eq("coach_id", coach_id);
    if (nullError) throw new Error("Failed to delete coach: " + nullError.message);

    const { data, error: delError } = await supabaseAdmin
      .from("coach_master")
      .delete()
      .eq("coach_id", coach_id)
      .select();

    if (delError) throw new Error("Failed to delete coach: " + delError.message);

    if (!data || data.length === 0) {
      return false;
    }

    return true;
  }

  async coachNumberExists(trainId, coachNumber, excludeId = null) {
    let query = supabaseAdmin
      .from("coaches")
      .select("id")
      .eq("train_id", trainId)
      .eq("coach_number", coachNumber);

    if (excludeId) {
      query = query.neq("id", excludeId);
    }

    const { data, error } = await query;
    if (error) throw error;
    return (data || []).length > 0;
  }

  async findUnmappedCoaches() {
    const { data: mappedIds } = await supabaseAdmin
      .from("master_module")
      .select("coach_id")
      .not("coach_id", "is", null);

    const excludedIds = mappedIds ? mappedIds.map(m => m.coach_id) : [];

    let query = supabaseAdmin.from("coach_master").select("*");
    if (excludedIds.length > 0) {
      query = query.not("coach_id", "in", `(${excludedIds.join(",")})`);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  }

  async getAllCoachesWithDetails() {
    const { data: rows, error } = await supabaseAdmin
      .from("coach_master")
      .select("*");
    if (error) throw new Error("Failed to fetch coaches: " + error.message);
    if (!rows || rows.length === 0) return [];

    const makeIds = [...new Set(rows.filter(r => r.make_of_coach).map(r => r.make_of_coach))];
    const typeIds = [...new Set(rows.filter(r => r.type_of_coach).map(r => r.type_of_coach))];
    const userIds = [...new Set(rows.flatMap(r => [r.created_by, r.updated_by].filter(Boolean)))];

    let makeMap = {};
    if (makeIds.length > 0) {
      const { data: makes } = await supabaseAdmin.from("coach_make").select("id, name").in("id", makeIds);
      for (const m of makes || []) makeMap[m.id] = m;
    }

    let typeMap = {};
    if (typeIds.length > 0) {
      const { data: types } = await supabaseAdmin.from("coach_type").select("id, code").in("id", typeIds);
      for (const t of types || []) typeMap[t.id] = t;
    }

    let userMap = {};
    if (userIds.length > 0) {
      const { data: users } = await supabaseAdmin.from("user_master").select("user_id, first_name").in("user_id", userIds);
      for (const u of users || []) userMap[u.user_id] = u;
    }

    const coachIds = rows.map(r => r.coach_id);
    let mmByCoach = {};
    if (coachIds.length > 0) {
      const { data: modules } = await supabaseAdmin
        .from("master_module")
        .select("coach_id, module_unique_id, location")
        .in("coach_id", coachIds);
      for (const mm of modules || []) {
        if (!mmByCoach[mm.coach_id]) mmByCoach[mm.coach_id] = [];
        mmByCoach[mm.coach_id].push(mm);
      }
    }

    return rows.map(c => {
      const modules = mmByCoach[c.coach_id] || [];
      return {
        coach_id: c.coach_id,
        coach_unique_id: c.coach_unique_id,
        coach_display_id: c.coach_display_id,
        position: c.position,
        no_of_master_module: c.no_of_master_module,
        created_by: c.created_by,
        coach_status: c.coach_status,
        entity_type: c.entity_type || '',
        manufacturing_year: c.manufacturing_year,
        created_by_name: c.created_by ? (userMap[c.created_by] ? userMap[c.created_by].first_name : null) : null,
        created_date: c.created_date,
        updated_by: c.updated_by,
        updated_by_name: c.updated_by ? (userMap[c.updated_by] ? userMap[c.updated_by].first_name : null) : null,
        updated_date: c.updated_date,
        make_of_coach_name: c.make_of_coach ? (makeMap[c.make_of_coach] ? makeMap[c.make_of_coach].name : '') : '',
        make_of_coach_id: c.make_of_coach,
        type_of_coach_code: c.type_of_coach ? (typeMap[c.type_of_coach] ? typeMap[c.type_of_coach].code : '') : '',
        type_of_coach_id: c.type_of_coach,
        master_module_ids: modules.map(mm => mm.module_unique_id).join(', '),
        master_module_locations: modules.map(mm => mm.location).join(', ')
      };
    });
  }

  async getCoachForTrain(trainId) {
    const { data, error } = await supabaseAdmin
      .from("coach_master")
      .select("coach_id, coach_unique_id")
      .eq("train_id", trainId);
    if (error) throw error;
    return data || [];
  }
}

module.exports = new CoachModel();
