const supabaseAdmin = require('../config/supabaseAdmin');
const { toMySQLDatetime } = require('../middleware/datetime');
const BaseModel = require('./base.model');

class StationModel extends BaseModel {
    constructor() {
        super('stations');
    }

    async getAllStations() {
        const { data: rows, error } = await supabaseAdmin
            .from('stations')
            .select('*')
            .eq('is_station', 1);
        if (error) throw error;
        return rows;
    }
}

module.exports = new StationModel();
