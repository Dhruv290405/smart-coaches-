const BaseModel = require('./base.model');
const supabaseAdmin = require('../config/supabaseAdmin');

class TrainModel extends BaseModel {
  constructor() {
    super('train_master');
  }

  async createTrain(data) {
    const created_at = new Date().toISOString();

    const { data: trainData, error: trainError } = await supabaseAdmin
      .from('train_master')
      .insert([{
        train_number: data.train_number,
        train_name: data.train_name,
        origination_region_id: data.origination_region_id,
        region_id: data.region_id,
        departure_station_id: data.departure_station_id,
        destination_station_id: data.destination_station_id,
        no_of_coaches: data.no_of_coaches,
        line: data.line,
        train_operator: data.train_operator,
        engine_number: data.engine_number,
        created_by: data.created_by,
        created_at: created_at
      }])
      .select();

    if (trainError) throw new Error('Failed to create train: ' + trainError.message);

    const train_id = trainData[0].train_id;

    if (data.coaches.length > 0) {
      for (const coach of data.coaches) {
        const { data: coachRow } = await supabaseAdmin
          .from('coach_master')
          .select('coach_id')
          .eq('coach_unique_id', coach.coach_unique_id)
          .maybeSingle();

        if (!coachRow) {
          const { error: insError } = await supabaseAdmin
            .from('coach_master')
            .insert([{
              entity_type: coach.entity_type,
              coach_unique_id: coach.coach_unique_id,
              coach_display_id: coach.coach_display_id,
              position: coach.position,
              train_id: train_id,
              created_by: data.created_by,
              created_date: created_at
            }]);
          if (insError) throw new Error('Failed to create train: ' + insError.message);
        } else {
          const { error: updError } = await supabaseAdmin
            .from('coach_master')
            .update({
              entity_type: coach.entity_type,
              train_id: train_id,
              coach_display_id: coach.coach_display_id,
              position: coach.position,
              updated_by: data.created_by,
              updated_date: created_at
            })
            .eq('coach_id', coachRow.coach_id);
          if (updError) throw new Error('Failed to create train: ' + updError.message);
        }
      }
    }

    return train_id;
  }

  async getAllTrains() {
    const { data: trains, error } = await supabaseAdmin
      .from('train_master')
      .select('*')
      .order('train_id');
    if (error) throw error;
    if (!trains || trains.length === 0) return [];

    const userIds = [...new Set(trains.flatMap(t => [t.created_by, t.updated_by].filter(Boolean)))];
    const regionIds = [...new Set(trains.flatMap(t => [t.origination_region_id, t.region_id, t.departure_station_id, t.destination_station_id].filter(Boolean)))];

    let userMap = {};
    if (userIds.length > 0) {
      const { data: users } = await supabaseAdmin.from('user_master').select('user_id, first_name').in('user_id', userIds);
      for (const u of users || []) userMap[u.user_id] = u;
    }

    let regionMap = {};
    if (regionIds.length > 0) {
      const { data: regions } = await supabaseAdmin.from('region_master').select('region_id, name').in('region_id', regionIds);
      for (const r of regions || []) regionMap[r.region_id] = r;
    }

    const trainIds = trains.map(t => t.train_id);
    let coachesByTrain = {};
    if (trainIds.length > 0) {
      const { data: coaches } = await supabaseAdmin
        .from('coach_master')
        .select('*')
        .in('train_id', trainIds)
        .order('position');
      for (const c of coaches || []) {
        if (!coachesByTrain[c.train_id]) coachesByTrain[c.train_id] = [];
        coachesByTrain[c.train_id].push(c);
      }
    }

    const rows = [];
    for (const t of trains) {
      const coaches = coachesByTrain[t.train_id] || [];
      for (const c of coaches) {
        rows.push({
          train_id: t.train_id,
          train_number: t.train_number,
          train_name: t.train_name,
          origination_region_id: t.origination_region_id,
          region_id: t.region_id,
          departure_station_id: t.departure_station_id,
          destination_station_id: t.destination_station_id,
          line: t.line,
          train_operator: t.train_operator,
          engine_number: t.engine_number,
          created_at: t.created_at,
          updated_at: t.updated_at,
          created_by: t.created_by ? (userMap[t.created_by] ? userMap[t.created_by].first_name : null) : null,
          updated_by: t.updated_by ? (userMap[t.updated_by] ? userMap[t.updated_by].first_name : null) : null,
          origination_region_name: t.origination_region_id ? (regionMap[t.origination_region_id] ? regionMap[t.origination_region_id].name : null) : null,
          region_name: t.region_id ? (regionMap[t.region_id] ? regionMap[t.region_id].name : null) : null,
          departure_station_name: t.departure_station_id ? (regionMap[t.departure_station_id] ? regionMap[t.departure_station_id].name : null) : null,
          destination_station_name: t.destination_station_id ? (regionMap[t.destination_station_id] ? regionMap[t.destination_station_id].name : null) : null,
          coach_id: c.coach_id,
          coach_unique_id: c.coach_unique_id,
          coach_display_id: c.coach_display_id,
          entity_type: c.entity_type,
          position: c.position
        });
      }
      if (coaches.length === 0) {
        rows.push({
          train_id: t.train_id,
          train_number: t.train_number,
          train_name: t.train_name,
          origination_region_id: t.origination_region_id,
          region_id: t.region_id,
          departure_station_id: t.departure_station_id,
          destination_station_id: t.destination_station_id,
          line: t.line,
          train_operator: t.train_operator,
          engine_number: t.engine_number,
          created_at: t.created_at,
          updated_at: t.updated_at,
          created_by: t.created_by ? (userMap[t.created_by] ? userMap[t.created_by].first_name : null) : null,
          updated_by: t.updated_by ? (userMap[t.updated_by] ? userMap[t.updated_by].first_name : null) : null,
          origination_region_name: t.origination_region_id ? (regionMap[t.origination_region_id] ? regionMap[t.origination_region_id].name : null) : null,
          region_name: t.region_id ? (regionMap[t.region_id] ? regionMap[t.region_id].name : null) : null,
          departure_station_name: t.departure_station_id ? (regionMap[t.departure_station_id] ? regionMap[t.departure_station_id].name : null) : null,
          destination_station_name: t.destination_station_id ? (regionMap[t.destination_station_id] ? regionMap[t.destination_station_id].name : null) : null,
          coach_id: null,
          coach_unique_id: null,
          coach_display_id: null,
          entity_type: null,
          position: null
        });
      }
    }

    return rows;
  }

  async updateTrain(data) {
    const updated_at = new Date().toISOString();

    const { error: updError } = await supabaseAdmin
      .from('train_master')
      .update({
        train_number: data.train_number,
        train_name: data.train_name,
        origination_region_id: data.origination_region_id,
        region_id: data.region_id,
        departure_station_id: data.departure_station_id,
        destination_station_id: data.destination_station_id,
        no_of_coaches: data.no_of_coaches,
        line: data.line,
        train_operator: data.train_operator,
        engine_number: data.engine_number,
        updated_by: data.updated_by,
        updated_at: updated_at
      })
      .eq('train_id', data.train_id);
    if (updError) throw new Error('Failed to update train: ' + updError.message);

    const { error: delError } = await supabaseAdmin
      .from('train_coach_mapping')
      .delete()
      .eq('train_id', data.train_id);
    if (delError) throw new Error('Failed to update train: ' + delError.message);

    if (data.coaches?.length > 0) {
      for (const coach of data.coaches) {
        const { data: coachRow, error: findError } = await supabaseAdmin
          .from('coach_master')
          .select('coach_id')
          .eq('coach_unique_id', coach.coach_unique_id)
          .maybeSingle();
        if (findError) throw new Error('Failed to update train: ' + findError.message);
        if (!coachRow) {
          throw new Error(`Coach with unique number ${coach.coach_unique_id} not found.`);
        }

        const { error: insError } = await supabaseAdmin
          .from('train_coach_mapping')
          .insert([{
            train_id: data.train_id,
            coach_id: coachRow.coach_id,
            coach_display_id: coach.coach_display_id,
            position: coach.position,
            is_active: 1
          }]);
        if (insError) throw new Error('Failed to update train: ' + insError.message);
      }
    }
  }

  async deleteTrain(train_id, updated_by) {
    const { error: delMapError } = await supabaseAdmin
      .from('train_coach_mapping')
      .delete()
      .eq('train_id', train_id);
    if (delMapError) throw new Error('Failed to delete train: ' + delMapError.message);

    const { error: delTrainError } = await supabaseAdmin
      .from('train_master')
      .delete()
      .eq('train_id', train_id);
    if (delTrainError) throw new Error('Failed to delete train: ' + delTrainError.message);
  }

  async getAll(filters = {}) {
    let query = supabaseAdmin
      .from('train_master')
      .select('*');

    if (filters.onlyTrainIdMinusOne) {
      query = query.eq('train_id', -1);
    } else {
      if (Array.isArray(filters.region_ids) && filters.region_ids.length > 0) {
        query = query.or(`origination_region_id.in.(${filters.region_ids.join(',')}),train_id.eq.-1`);
      }

      if (filters.search) {
        const term = `%${filters.search}%`;
        query = query.or(`train_number.ilike.${term},train_name.ilike.${term}`);
      }
    }

    const { data: trains, error } = await query.order('train_id');
    if (error) throw error;
    if (!trains || trains.length === 0) return [];

    const regionIds = [...new Set(trains.flatMap(t => [t.origination_region_id, t.region_id, t.departure_station_id, t.destination_station_id].filter(Boolean)))];

    let regionMap = {};
    if (regionIds.length > 0) {
      const { data: regions } = await supabaseAdmin.from('region_master').select('region_id, name').in('region_id', regionIds);
      for (const r of regions || []) regionMap[r.region_id] = r;
    }

    return trains.map(t => ({
      ...t,
      origination_region_name: t.origination_region_id ? (regionMap[t.origination_region_id] ? regionMap[t.origination_region_id].name : null) : null,
      region_name: t.region_id ? (regionMap[t.region_id] ? regionMap[t.region_id].name : null) : null,
      departure_station_name: t.departure_station_id ? (regionMap[t.departure_station_id] ? regionMap[t.departure_station_id].name : null) : null,
      destination_station_name: t.destination_station_id ? (regionMap[t.destination_station_id] ? regionMap[t.destination_station_id].name : null) : null
    }));
  }

  async getTrainsMappedToUser(userId) {
    const { data: specialTrainRows } = await supabaseAdmin
      .from('user_train_mapping')
      .select('train_id')
      .eq('user_id', userId)
      .eq('train_id', -1);

    if (specialTrainRows && specialTrainRows.length > 0) {
      const { data: regionRows } = await supabaseAdmin
        .from('user_region_mapping')
        .select('region_id')
        .eq('user_id', userId);

      const regionIds = (regionRows || []).map(r => r.region_id);
      if (regionIds.length === 0) return [];

      const { data: trains, error } = await supabaseAdmin
        .from('train_master')
        .select('*, region_master!origination_region_id(name)')
        .in('origination_region_id', regionIds)
        .order('train_number');
      if (error) throw error;

      return (trains || []).map(t => ({
        ...t,
        region_name: t.region_master ? t.region_master.name : null,
        region_master: undefined
      }));
    }

    const { data: mappedTrainIds } = await supabaseAdmin
      .from('user_train_mapping')
      .select('train_id')
      .eq('user_id', userId);

    const allowedIds = (mappedTrainIds || []).map(r => r.train_id);
    if (allowedIds.length === 0) return [];

    const { data: rows, error } = await supabaseAdmin
      .from('train_master')
      .select('*, region_master!origination_region_id(name)')
      .in('train_id', allowedIds)
      .order('train_number');
    if (error) throw error;

    return (rows || []).map(t => ({
      ...t,
      region_name: t.region_master ? t.region_master.name : null,
      region_master: undefined
    }));
  }

  async updateTrainUserMapping(userId, trainIds) {
    const { error: delError } = await supabaseAdmin
      .from('user_train_mapping')
      .delete()
      .eq('user_id', userId);
    if (delError) throw delError;

    if (trainIds.length > 0) {
      const values = trainIds.map(trainId => ({ user_id: userId, train_id: trainId }));
      const { error: insError } = await supabaseAdmin
        .from('user_train_mapping')
        .insert(values);
      if (insError) throw insError;
    }
  }

  async getById(id) {
    const { data: train, error } = await supabaseAdmin
      .from('train_master')
      .select('*')
      .eq('train_id', id)
      .maybeSingle();
    if (error) throw error;
    if (!train) return null;

    let zone_name = null, division_name = null, region_name = null;

    if (train.zone_id) {
      const { data: zone } = await supabaseAdmin.from('zones').select('name').eq('id', train.zone_id).maybeSingle();
      zone_name = zone ? zone.name : null;
    }
    if (train.division_id) {
      const { data: div } = await supabaseAdmin.from('divisions').select('name').eq('id', train.division_id).maybeSingle();
      division_name = div ? div.name : null;
    }
    if (train.origination_region_id) {
      const { data: reg } = await supabaseAdmin.from('regions').select('name').eq('id', train.origination_region_id).maybeSingle();
      region_name = reg ? reg.name : null;
    }

    return {
      ...train,
      zone_name,
      division_name,
      region_name
    };
  }

  async getCoaches(trainId) {
    const { data, error } = await supabaseAdmin
      .from('coaches')
      .select('*')
      .eq('train_id', trainId)
      .order('coach_number');
    if (error) throw error;
    return data || [];
  }

  async trainNumberExists(train_number, excludeId = null) {
    let query = supabaseAdmin.from('train_master').select('train_id').eq('train_number', train_number);
    if (excludeId) {
      query = query.neq('train_id', excludeId);
    }
    const { data, error } = await query;
    if (error) throw error;
    return (data || []).length > 0;
  }

  async getTrainsForUsers() {
    const { data, error } = await supabaseAdmin
      .from('train_master')
      .select('train_id, train_number, train_name');
    if (error) throw error;
    return data || [];
  }
}

module.exports = new TrainModel();
