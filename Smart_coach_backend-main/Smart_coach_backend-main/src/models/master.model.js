const supabaseAdmin = require('../config/supabaseAdmin');
const BaseModel = require('./base.model');

class MasterModel extends BaseModel {
  constructor(tableName) {
    super(tableName);
  }

  async getAllActive(filter = {}, orFilter = {}) {
    let query = supabaseAdmin
      .from(this.tableName)
      .select('*');

    query = query.eq('is_active', 1);

    for (const [key, value] of Object.entries(filter)) {
      query = query.eq(key, value);
    }

    if (Object.keys(orFilter).length > 0) {
      const orConditions = Object.entries(orFilter).map(([key, value]) => `${key}.eq.${value}`);
      query = query.or(orConditions.join(','));
    }

    query = query.order('name');

    const { data: rows, error } = await query;
    if (error) throw error;
    return rows;
  }

  async getActiveCount(filter = {}) {
    let query = supabaseAdmin
      .from(this.tableName)
      .select('*', { count: 'exact', head: true });

    query = query.eq('is_active', 1);

    for (const [key, value] of Object.entries(filter)) {
      query = query.eq(key, value);
    }

    const { count, error } = await query;
    if (error) throw error;
    return count;
  }

  async toggleStatus(id) {
    const { data: current, error: fetchError } = await supabaseAdmin
      .from(this.tableName)
      .select('is_active')
      .eq('id', id)
      .single();
    if (fetchError) throw fetchError;

    const { error: updateError } = await supabaseAdmin
      .from(this.tableName)
      .update({ is_active: current.is_active === 1 ? 0 : 1 })
      .eq('id', id);
    if (updateError) throw updateError;
    return true;
  }
}

module.exports = {
  zoneModel: new MasterModel('zone_master'),
  divisionModel: new MasterModel('division_master'),
  regionModel: new MasterModel('region_master'),
  roleModel: new MasterModel('role_master')
};
