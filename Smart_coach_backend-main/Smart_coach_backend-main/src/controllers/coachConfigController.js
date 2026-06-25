const CoachConfigModel = require("../models/coachConfig.model");

const coachConfigController = {
    getCoachDetails: async (req, res) => {
        try {
            const { coach_no } = req.params;
            const details = await CoachConfigModel.getDetailsByCoach(coach_no);

            if (!details) {
                return res.status(404).json({ 
                    success: false, 
                    message: `Coach "${coach_no}" not found in master data. Ensure the coach_unique_id exists in coach_master table with matching LEFT JOINs to train_master, master_module, module_device_mapping, and device_master.`
                });
            }

            const fittedDevices = details.fitted_devices || [];

            res.status(200).json({
                success: true,
                coach_info: {
                    coach_no: details.coach_no,
                    coach_type: details.coach_type || '',
                    rake_no: details.rake_no || '',
                    wsp_make: details.wsp_make || 'N/A'
                },
                fitted_devices: fittedDevices,
                full_config: {
                    id: details.coach_id || 0,
                    rake_no: details.rake_no || '',
                    coach_no: details.coach_no,
                    coach_type: details.coach_type || '',
                    wsp_make: details.wsp_make || 'N/A',
                    wli_sensor: fittedDevices.some((d) => d.toLowerCase().includes('water')) ? 'FITTED' : 'NOT FITTED',
                    fsds_sensor: fittedDevices.some((d) => d.toLowerCase().includes('fsds')) ? 'FITTED' : 'NOT FITTED',
                    bc_pressure: fittedDevices.some((d) => d.toLowerCase().includes('bc pressure') || d.toLowerCase().includes('brake')) ? 'FITTED' : 'NOT FITTED',
                    wsp_wifi: 'NOT FITTED',
                    hot_axle_detector: fittedDevices.some((d) => d.toLowerCase().includes('hot axle') || d.toLowerCase().includes('axle')) ? 'FITTED' : 'NOT FITTED',
                    acp_buzzer_alert: fittedDevices.some((d) => d.toLowerCase().includes('acp')) ? 'FITTED' : 'NOT FITTED',
                    acp_electrical_conn: 'NOT FITTED',
                    bad_odour_alert: fittedDevices.some((d) => d.toLowerCase().includes('odour') || d.toLowerCase().includes('odor')) ? 'FITTED' : 'NOT FITTED',
                    created_at: ''
                }
            });

        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = coachConfigController;
