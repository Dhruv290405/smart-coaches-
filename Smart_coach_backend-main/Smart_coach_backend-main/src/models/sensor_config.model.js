const BaseModel = require("./base.model");
const supabaseAdmin = require("../config/supabaseAdmin");

class Sensor_configModel extends BaseModel {
  constructor() {
    super("sensor_config");
  }

  async getSensorTypeId(device_id) {
    const { data, error } = await supabaseAdmin
      .from("sensor_device_mapping")
      .select("sensor_id")
      .eq("device_id", device_id)
      .maybeSingle();
    if (error) throw error;
    return data ? data.sensor_id : null;
  }

  async getRuleId(sensor_type_id) {
    const { data, error } = await supabaseAdmin
      .from("rule_sensor_mapping")
      .select("rule_id")
      .eq("sensor_type_id", sensor_type_id)
      .maybeSingle();
    if (error) throw error;
    return data ? data.rule_id : null;
  }

  async insertSensorConfig({
    sensor_id,
    device_id,
    sensor_type_id,
    rule_id,
    sensor_make_id,
    install_date,
    placement,
    location,
    remarks,
    master_module_id,
    coach_id
  }) {
    const { data: existing, error: findError } = await supabaseAdmin
      .from("sensor_config")
      .select("sensor_config_id")
      .eq("sensor_id", sensor_id)
      .maybeSingle();
    if (findError) throw findError;

    if (existing) {
      throw new Error(`Sensor with ID "${sensor_id}" already exists.`);
    }

    const { data: result, error: insError } = await supabaseAdmin
      .from("sensor_config")
      .insert([{
        sensor_id,
        device_id,
        sensor_type_id,
        rule_id,
        sensor_make_id,
        install_date,
        placement,
        location,
        remarks,
        master_module_id,
        coach_id
      }])
      .select();

    if (insError) throw insError;
    return result[0].sensor_config_id;
  }

  async getAllSensorConfigs() {
    const { data: rows, error } = await supabaseAdmin
      .from("sensor_config")
      .select(`
        *,
        device_master:device_id(tech_coach_no, comm_coach_no, train_no, train_location)
      `)
      .order("sensor_config_id", { ascending: false });
    if (error) throw error;

    return (rows || []).map(r => ({
      ...r,
      tech_coach_no: r.device_master ? r.device_master.tech_coach_no || '' : '',
      comm_coach_no: r.device_master ? r.device_master.comm_coach_no || '' : '',
      train_no: r.device_master ? r.device_master.train_no || '' : '',
      train_location: r.device_master ? r.device_master.train_location || '' : '',
      device_master: undefined
    }));
  }

  async noOfDevicesAttachedToModule(module_id) {
    const { count, error } = await supabaseAdmin
      .from("module_device_mapping")
      .select("*", { count: "exact", head: true })
      .eq("module_id", module_id);
    if (error) throw error;
    return count || 0;
  }

  async updateSensorConfig(sensor_config_id, {
    sensor_id,
    device_id,
    sensor_make_id,
    install_date,
    placement,
    location,
    remarks
  }) {
    const { data: existing, error: findError } = await supabaseAdmin
      .from("sensor_config")
      .select("sensor_config_id")
      .eq("sensor_id", sensor_id)
      .neq("sensor_config_id", sensor_config_id)
      .maybeSingle();
    if (findError) throw findError;

    if (existing) {
      throw new Error(`Sensor ID "${sensor_id}" already exists in another config.`);
    }

    const { data, error: updError } = await supabaseAdmin
      .from("sensor_config")
      .update({
        sensor_id,
        device_id,
        sensor_make_id,
        install_date,
        placement,
        location,
        remarks
      })
      .eq("sensor_config_id", sensor_config_id)
      .select();

    if (updError) throw updError;
    return data && data.length > 0;
  }

  async deleteSensorConfig(sensor_config_id) {
    const { data, error } = await supabaseAdmin
      .from("sensor_config")
      .delete()
      .eq("sensor_config_id", sensor_config_id)
      .select();

    if (error) throw error;

    console.log(`Deleted sensor config with ID ${sensor_config_id}`);

    return data && data.length > 0;
  }

  async getTrainAndCoachBySensorId(sensor_id) {
    const { data: row, error } = await supabaseAdmin
      .from("sensor_config")
      .select("coach_id")
      .eq("sensor_id", sensor_id)
      .maybeSingle();

    if (error) throw error;

    const coach_id = row ? row.coach_id : null;

    if (!coach_id) {
      return null;
    }

    await supabaseAdmin
      .from("coach_master")
      .select("coach_id")
      .eq("coach_id", coach_id);

    const train_id = null;

    return { coach_id, train_id };
  }
}

module.exports = new Sensor_configModel();
