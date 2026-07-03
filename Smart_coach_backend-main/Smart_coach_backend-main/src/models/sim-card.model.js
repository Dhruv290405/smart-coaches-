const supabaseAdmin = require('../config/supabaseAdmin');
const BaseModel = require('./base.model');

class SimCardModel extends BaseModel {
  constructor() {
    super('sim_cards');
  }

  async getAll(filters = {}, page = 1, limit = 10) {
    const offset = (page - 1) * limit;

    let query = supabaseAdmin
      .from('sim_cards')
      .select(`
        *,
        master_modules!left(
          name,
          serial_number,
          coaches!left(coach_number, trains!left(number, name))
        ),
        carriers!left(name)
      `);

    if (filters.master_module_id) {
      query = query.eq('master_module_id', filters.master_module_id);
    }

    if (filters.carrier_id) {
      query = query.eq('carrier_id', filters.carrier_id);
    }

    if (filters.status) {
      query = query.eq('status', filters.status);
    }

    if (filters.search) {
      query = query.or(`phone_number.ilike.%${filters.search}%,iccid.ilike.%${filters.search}%,imsi.ilike.%${filters.search}%`);
    }

    query = query.order('phone_number').range(offset, offset + limit - 1);

    const { data: simCards, error } = await query;
    if (error) throw error;

    const rows = [];
    for (const sc of simCards || []) {
      const row = { ...sc };
      if (sc.master_modules) {
        row.master_module_name = sc.master_modules.name || null;
        row.master_module_serial = sc.master_modules.serial_number || null;
        if (sc.master_modules.coaches) {
          row.coach_number = sc.master_modules.coaches.coach_number || null;
          if (sc.master_modules.coaches.trains) {
            row.train_number = sc.master_modules.coaches.trains.number || null;
            row.train_name = sc.master_modules.coaches.trains.name || null;
          }
        }
      }
      if (sc.carriers) {
        row.carrier_name = sc.carriers.name || null;
      }
      delete row.master_modules;
      delete row.carriers;
      rows.push(row);
    }

    return rows;
  }

  async getById(id) {
    const { data: rows, error } = await supabaseAdmin
      .from('sim_cards')
      .select(`
        *,
        master_modules!left(
          name,
          serial_number,
          coaches!left(coach_number, trains!left(number, name))
        ),
        carriers!left(name)
      `)
      .eq('id', id);

    if (error) throw error;

    if (!rows || rows.length === 0) return null;

    const sc = rows[0];
    const row = { ...sc };
    if (sc.master_modules) {
      row.master_module_name = sc.master_modules.name || null;
      row.master_module_serial = sc.master_modules.serial_number || null;
      if (sc.master_modules.coaches) {
        row.coach_number = sc.master_modules.coaches.coach_number || null;
        if (sc.master_modules.coaches.trains) {
          row.train_number = sc.master_modules.coaches.trains.number || null;
          row.train_name = sc.master_modules.coaches.trains.name || null;
        }
      }
    }
    if (sc.carriers) {
      row.carrier_name = sc.carriers.name || null;
    }
    delete row.master_modules;
    delete row.carriers;

    return row;
  }

  async phoneNumberExists(phoneNumber, excludeId = null) {
    let query = supabaseAdmin
      .from('sim_cards')
      .select('id')
      .eq('phone_number', phoneNumber);

    if (excludeId) {
      query = query.neq('id', excludeId);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data.length > 0;
  }

  async iccidExists(iccid, excludeId = null) {
    let query = supabaseAdmin
      .from('sim_cards')
      .select('id')
      .eq('iccid', iccid);

    if (excludeId) {
      query = query.neq('id', excludeId);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data.length > 0;
  }

  async imsiExists(imsi, excludeId = null) {
    if (!imsi) return false;

    let query = supabaseAdmin
      .from('sim_cards')
      .select('id')
      .eq('imsi', imsi);

    if (excludeId) {
      query = query.neq('id', excludeId);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data.length > 0;
  }

  async masterModuleHasSim(masterModuleId, excludeId = null) {
    if (!masterModuleId) return false;

    let query = supabaseAdmin
      .from('sim_cards')
      .select('id')
      .eq('master_module_id', masterModuleId);

    if (excludeId) {
      query = query.neq('id', excludeId);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data.length > 0;
  }
}

module.exports = new SimCardModel();
