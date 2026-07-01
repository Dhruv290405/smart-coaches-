const supabaseAdmin = require('../config/supabaseAdmin');
const { toMySQLDatetime } = require('../middleware/datetime');
const BaseModel = require('./base.model');

class StationModel extends BaseModel {
    constructor() {
        super('region_master');
    }

    async getAllStations() {
        const { data: rows, error } = await supabaseAdmin
            .from('region_master')
            .select('*')
            .eq('is_station', 1)
            .neq('region_id', -1);
        if (error) throw error;
        return rows;
    }
}

module.exports = new StationModel();
