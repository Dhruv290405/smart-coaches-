const CoachConfigModel = require("../models/coachConfig.model");

const coachConfigController = {
    getCoachDetails: async (req, res) => {
        try {
            const { coach_no } = req.params;
            const details = await CoachConfigModel.getDetailsByCoach(coach_no);

            if (!details) {
                return res.status(404).json({ 
                    success: false, 
                    message: "Coach details not found in master data" 
                });
            }

            const fittedDevices = [];
            if (details.wli_sensor !== 'NOT FITTED') fittedDevices.push("Water Level Sensor");
            if (details.fsds_sensor !== 'NOT FITTED') fittedDevices.push("FSDS Sensor");
            if (details.bc_pressure !== 'NOT FITTED') fittedDevices.push("BC Pressure");
            if (details.hot_axle_detector !== 'NOT FITTED') fittedDevices.push("Hot Axle Box Detector");
            if (details.bad_odour_alert !== 'NOT FITTED') fittedDevices.push("Bad Odour Alert");
            if (details.brake_binding !== 'NOT FITTED' && details.brake_binding !== undefined) {
                fittedDevices.push("Brake Binding");
            }

            //  ACP KE LIYE YEH CHECKS ADD KAREIN
            if (details.acp_buzzer_alert !== 'NOT FITTED' && details.acp_buzzer_alert !== undefined) {
                fittedDevices.push("ACP Buzzer Alert");
            }
            if (details.acp_electrical_conn !== 'NOT FITTED' && details.acp_electrical_conn !== undefined) {
                fittedDevices.push("ACP Electrical Connection");
            }

            res.status(200).json({
                success: true,
                coach_info: {
                    coach_no: details.coach_no,
                    coach_type: details.coach_type,
                    rake_no: details.rake_no,
                    wsp_make: details.wsp_make
                },
                fitted_devices: fittedDevices,
                full_config: details
            });

        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = coachConfigController;