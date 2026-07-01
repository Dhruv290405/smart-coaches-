const supabaseAdmin = require('../config/supabaseAdmin');
const { toMySQLDatetime } = require('../middleware/datetime');
const BaseModel = require('./base.model');

class RegionsModel extends BaseModel {
    constructor() {
        super('region_master');
    }

    async getAllRegions() {
        const { data: rows, error } = await supabaseAdmin
            .from('region_master')
            .select('*')
            .eq('is_region', 1)
            .neq('region_id', -1);
        if (error) throw error;
        return rows;
    }
}

module.exports = new RegionsModel();
