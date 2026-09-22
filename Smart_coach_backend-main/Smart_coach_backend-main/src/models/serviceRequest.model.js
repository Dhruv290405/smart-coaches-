const supabaseAdmin = require("../config/supabaseAdmin");

const ServiceRequestModel = {
    async create(data) {
        try {
            const { data: result, error } = await supabaseAdmin
                .from("service_requests")
                .insert({
                    train_no: data.train_no,
                    coach_no: data.coach_no,
                    seat_berth: data.seat_berth,
                    service_type: data.service_type,
                    description: data.description || null,
                    passenger_name: data.passenger_name || null,
                    passenger_phone: data.passenger_phone || null,
                    status: "pending"
                })
                .select()
                .single();

            if (error) throw error;
            return result;
        } catch (err) {
            console.error("ServiceRequest Model create error:", err.message);
            throw err;
        }
    },

    async getAll({ status, limit = 50, offset = 0 } = {}) {
        try {
            let query = supabaseAdmin
                .from("service_requests")
                .select("*", { count: "exact" });

            if (status) {
                query = query.eq("status", status);
            }

            query = query.order("created_at", { ascending: false });

            if (limit) query = query.limit(limit);
            if (offset) query = query.range(offset, offset + limit - 1);

            const { data, error, count } = await query;
            if (error) throw error;
            return { data: data || [], count };
        } catch (err) {
            console.error("ServiceRequest Model getAll error:", err.message);
            throw err;
        }
    },

    async getById(id) {
        try {
            const { data, error } = await supabaseAdmin
                .from("service_requests")
                .select("*")
                .eq("id", id)
                .single();

            if (error) throw error;
            return data;
        } catch (err) {
            console.error("ServiceRequest Model getById error:", err.message);
            throw err;
        }
    },

    async updateStatus(id, status, updatedBy) {
        try {
            const { data, error } = await supabaseAdmin
                .from("service_requests")
                .update({
                    status: status,
                    updated_at: new Date().toISOString()
                })
                .eq("id", id)
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (err) {
            console.error("ServiceRequest Model updateStatus error:", err.message);
            throw err;
        }
    }
};

module.exports = ServiceRequestModel;
