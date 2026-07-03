const supabaseAdmin = require('../config/supabaseAdmin');

class BaseModel {
  constructor(tableName) {
    this.tableName = tableName;
    this.supabase = supabaseAdmin;
  }

  async findOne(conditions) {
    try {
      const keys = Object.keys(conditions);
      let query = this.supabase.from(this.tableName).select('*');
      keys.forEach(key => {
        query = query.eq(key, conditions[key]);
      });
      const { data, error } = await query.limit(1).single();
      if (error) {
        if (error.code === 'PGRST116') return null;
        throw error;
      }
      return data || null;
    } catch (error) {
      console.error(error);
      throw error;
    }
  }

  async findAll(conditions = {}) {
    try {
      const keys = Object.keys(conditions);
      let query = this.supabase.from(this.tableName).select('*');
      keys.forEach(key => {
        query = query.eq(key, conditions[key]);
      });
      const { data, error } = await query;
      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error(error);
      throw error;
    }
  }

  async create(data) {
    try {
      const createdDateUTC = new Date();
      const finalData = {
        ...data,
        created_date: createdDateUTC
      };
      const { data: inserted, error } = await this.supabase
        .from(this.tableName)
        .insert([finalData])
        .select();
      if (error) throw error;
      return { id: inserted[0].id, ...finalData };
    } catch (error) {
      console.error(error);
      throw error;
    }
  }

  async update(id, data) {
    try {
      const { data: updated, error } = await this.supabase
        .from(this.tableName)
        .update(data)
        .eq('id', id)
        .select();
      if (error) throw error;
      return { id, ...data };
    } catch (error) {
      console.error(error);
      throw error;
    }
  }

  async delete(id) {
    try {
      const { error } = await this.supabase
        .from(this.tableName)
        .delete()
        .eq('id', id);
      if (error) throw error;
      return { id };
    } catch (error) {
      console.error(error);
      throw error;
    }
  }
}

module.exports = BaseModel;
