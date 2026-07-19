const BaseModel = require('./base.model');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const supabaseAdmin = require('../config/supabaseAdmin');

class UserModel extends BaseModel {
  constructor() {
    super('user_master');
  }

  async create(userData) {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(userData.password, salt);

    const regionForUser = Array.isArray(userData.region_id) && userData.region_id.length > 0
      ? userData.region_id[0] : (userData.region_id || null);

    const { data: user, error } = await supabaseAdmin
      .from('user_master')
      .insert({
        first_name: userData.first_name,
        last_name: userData.last_name || null,
        email: userData.email,
        password_hash: hashedPassword,
        mobile_number: userData.mobile_number,
        gender: userData.gender || null,
        organisation_type: userData.organisation_type,
        organisation_name: userData.organisation_name || null,
        zone_id: userData.zone_id,
        division_id: userData.division_id,
        role_id: userData.role_id,
        region_id: regionForUser,
        status: userData.status || 'Inactive',
        approval_status: userData.approval_status || 'Pending',
        created_date: new Date(),
        employee_id: userData.employee_id || null,
        pan_card_no: userData.pan_card_no || null,
        aadhar_no: userData.aadhar_no || null,
        company_id: userData.company_id || null
      })
      .select()
      .single();

    if (error) throw error;

    const userId = user.user_id;

    if (userData.region_id && Array.isArray(userData.region_id) && userData.region_id.length > 0) {
      let nextId = 1;
      const { data: maxRow } = await supabaseAdmin
        .from('user_region_mapping')
        .select('id')
        .order('id', { ascending: false })
        .limit(1)
        .maybeSingle();
      if (maxRow?.id) nextId = maxRow.id + 1;
      const regionValues = userData.region_id.map((id, i) => ({ id: nextId + i, user_id: userId, region_id: id }));
      const { error: regionError } = await supabaseAdmin
        .from('user_region_mapping')
        .insert(regionValues);
      if (regionError) throw regionError;
    }

    if (userData.train_ids && Array.isArray(userData.train_ids) && userData.train_ids.length > 0) {
      const trainValues = userData.train_ids.map(id => ({ user_id: userId, train_id: id }));
      const { error: trainError } = await supabaseAdmin
        .from('user_train_mapping')
        .insert(trainValues);
      if (trainError) throw trainError;
    }

    delete user.password_hash;
    return user;
  }

  async findByEmail(email) {
    const { data: user, error } = await supabaseAdmin
      .from('user_master')
      .select('*')
      .eq('email', email)
      .maybeSingle();
    if (error) throw error;
    return user || null;
  }

  async validatePassword(user, password) {
    return await bcrypt.compare(password, user.password_hash);
  }

  generateAuthToken(user) {
    const payload = {
      user_id: user.user_id,
      email: user.email,
      role_id: user.role_id,
      zone_id: user.zone_id,
      division_id: user.division_id,
      region_id: user.region_id,
      employee_id: user.employee_id
    };

    return jwt.sign(
      payload,
      process.env.JWT_SECRET || 'your_jwt_secret',
      { expiresIn: '30d' }
    );
  }

  async getPendingUsersByScope(currentUser, filters = {}) {
    let query = supabaseAdmin
      .from('user_master')
      .select(`
        user_id,
        first_name,
        last_name,
        email,
        mobile_number,
        organisation_type,
        created_date,
        employee_id,
        zone_id,
        division_id,
        pan_card_no,
        aadhar_no,
        role_id,
        approval_status,
        role_master!inner(name),
        zone_master!left(name),
        division_master!left(name),
        region_master!left(name)
      `);

    query = query.gt('role_id', currentUser.role_id);

    switch (currentUser.role_id) {
      case 3: {
        const orParts = [`and(role_id.eq.4,zone_id.eq.${currentUser.zone_id})`];
        const { data: divisions } = await supabaseAdmin
          .from('division_master')
          .select('division_id')
          .eq('zone_id', currentUser.zone_id);
        const divisionIds = divisions.map(d => d.division_id);
        if (divisionIds.length > 0) {
          const { data: regions } = await supabaseAdmin
            .from('region_master')
            .select('region_id')
            .in('division_id', divisionIds);
          const regionIds = regions.map(r => r.region_id);
          orParts.push(`and(role_id.in.(5,6),division_id.in.(${divisionIds.join(',')}))`);
          if (regionIds.length > 0) {
            orParts.push(`and(role_id.eq.7,region_id.in.(${regionIds.join(',')}))`);
          }
        }
        query = query.or(orParts.join(','));
        break;
      }
      case 4: {
        const orParts = [`and(role_id.in.(5,6),division_id.eq.${currentUser.division_id})`];
        const { data: regions } = await supabaseAdmin
          .from('region_master')
          .select('region_id')
          .eq('division_id', currentUser.division_id);
        const regionIds = regions.map(r => r.region_id);
        if (regionIds.length > 0) {
          orParts.push(`and(role_id.eq.7,region_id.in.(${regionIds.join(',')}))`);
        }
        query = query.or(orParts.join(','));
        break;
      }
      case 5: {
        query = query.eq('role_id', 7);
        const { data: regions } = await supabaseAdmin
          .from('region_master')
          .select('region_id')
          .eq('division_id', currentUser.division_id);
        const regionIds = regions.map(r => r.region_id);
        if (regionIds.length > 0) {
          query = query.in('region_id', regionIds);
        }
        break;
      }
    }

    if (filters.status) {
      const statuses = Array.isArray(filters.status) ? filters.status : [filters.status];
      query = query.in('approval_status', statuses);
    }

    if (filters.organisation_type) {
      const orgTypes = Array.isArray(filters.organisation_type) ? filters.organisation_type : [filters.organisation_type];
      query = query.in('organisation_type', orgTypes);
    }

    if (filters.from_date) {
      query = query.gte('created_date', filters.from_date);
    }

    if (filters.to_date) {
      query = query.lte('created_date', filters.to_date);
    }

    const { data: rows, error } = await query;
    if (error) throw error;

    const userIds = rows.map(r => r.user_id);
    const { data: allMappings } = await supabaseAdmin
      .from('user_region_mapping')
      .select('user_id, region_id')
      .in('user_id', userIds);

    const mappingsByUser = {};
    for (const m of allMappings || []) {
      if (!mappingsByUser[m.user_id]) mappingsByUser[m.user_id] = [];
      mappingsByUser[m.user_id].push(m.region_id);
    }

    const allRegionIds = [...new Set((allMappings || []).map(m => m.region_id).concat(rows.filter(r => r.region_id).map(r => r.region_id)))];
    const regionNameMap = {};
    if (allRegionIds.length > 0) {
      const { data: regionData } = await supabaseAdmin
        .from('region_master')
        .select('region_id, name')
        .in('region_id', allRegionIds);
      for (const r of regionData || []) {
        regionNameMap[r.region_id] = r.name;
      }
    }

    for (const row of rows) {
      const mapped = mappingsByUser[row.user_id] || [];
      if (mapped.length > 0) {
        row.region_ids = mapped.join(',');
        row.region_names = mapped.map(id => regionNameMap[id] || '').join(',');
      } else {
        row.region_ids = String(row.region_id || '');
        row.region_names = row.region_master?.name || null;
      }
      row.role = row.role_master?.name || null;
      row.zone_name = row.zone_master?.name || null;
      row.division_name = row.division_master?.name || null;
      delete row.role_master;
      delete row.zone_master;
      delete row.division_master;
      delete row.region_master;
    }

    return rows;
  }

  async approveUserWithRoleChange(userId, approvalStatus, roleId) {
    const updateData = { updated_date: new Date() };

    if (approvalStatus !== undefined && approvalStatus !== null && approvalStatus !== '') {
      updateData.approval_status = approvalStatus;
    }

    if (roleId !== undefined && roleId !== null && roleId !== '') {
      updateData.role_id = roleId;
    }

    const { error } = await supabaseAdmin
      .from('user_master')
      .update(updateData)
      .eq('user_id', userId);

    if (error) throw error;
  }

  async isApproverAuthorized(currentUser, targetUser, currentUserRole) {
    const currentRoleId = currentUser.role_id;
    const targetRoleId = targetUser.role_id;

    // Must be managing a lower role (higher role_id = lower in hierarchy)
    if (targetRoleId <= currentRoleId) return false;

    // Master (role_id=1) and Super Admin (role_id=2) can approve any lower role system-wide
    if (currentRoleId <= 2) return true;

    // Admin / Division Admin (role_id=3): same zone
    if (currentRoleId === 3) {
      if (targetUser.zone_id !== currentUser.zone_id) return false;
      if (targetRoleId === 4) return true;
      // For roles 5,6: same division within zone
      const { data: targetDivisions } = await supabaseAdmin
        .from('division_master')
        .select('division_id')
        .eq('zone_id', currentUser.zone_id);
      const zoneDivisionIds = targetDivisions.map(d => d.division_id);
      if (!zoneDivisionIds.includes(targetUser.division_id)) return false;
      if (targetRoleId === 5 || targetRoleId === 6) return true;
      // For role 7: same region within zone's divisions
      const { data: zoneRegions } = await supabaseAdmin
        .from('region_master')
        .select('region_id')
        .in('division_id', zoneDivisionIds);
      const zoneRegionIds = zoneRegions.map(r => r.region_id);
      const targetRegions = await this._getUserRegionIds(targetUser.user_id);
      return targetRegions.some(r => zoneRegionIds.includes(r));
    }

    // Manager / Division Manager (role_id=4): same division
    if (currentRoleId === 4) {
      if (targetUser.division_id !== currentUser.division_id) return false;
      if (targetRoleId === 5 || targetRoleId === 6) return true;
      // For role 7: same region within division
      const { data: divRegions } = await supabaseAdmin
        .from('region_master')
        .select('region_id')
        .eq('division_id', currentUser.division_id);
      const divRegionIds = divRegions.map(r => r.region_id);
      const targetRegions = await this._getUserRegionIds(targetUser.user_id);
      return targetRegions.some(r => divRegionIds.includes(r));
    }

    // Editor / Regional Master (role_id=5): role 7 only, same division's regions
    if (currentRoleId === 5) {
      if (targetRoleId !== 7) return false;
      const { data: divRegions } = await supabaseAdmin
        .from('region_master')
        .select('region_id')
        .eq('division_id', currentUser.division_id);
      const divRegionIds = divRegions.map(r => r.region_id);
      const targetRegions = await this._getUserRegionIds(targetUser.user_id);
      return targetRegions.some(r => divRegionIds.includes(r));
    }

    // Region Operator (6) and Train Operator (7) cannot approve anyone
    return false;
  }

  async _getUserRegionIds(userId) {
    const { data: mappings } = await supabaseAdmin
      .from('user_region_mapping')
      .select('region_id')
      .eq('user_id', userId);
    if (mappings && mappings.length > 0) {
      return mappings.map(m => m.region_id);
    }
    const { data: user } = await supabaseAdmin
      .from('user_master')
      .select('region_id')
      .eq('user_id', userId)
      .maybeSingle();
    return user?.region_id ? [user.region_id] : [];
  }

  async findOne(criteria) {
    const key = Object.keys(criteria)[0];
    const value = criteria[key];
    const { data, error } = await supabaseAdmin
      .from('user_master')
      .select(`*, zone_master!left(name), division_master!left(name), region_master!left(name)`)
      .eq(key, value)
      .maybeSingle();
    if (error) throw error;
    if (!data) return null;
    data.zone_name = data.zone_master?.name || null;
    data.division_name = data.division_master?.name || null;
    data.region_name = data.region_master?.name || null;
    delete data.zone_master;
    delete data.division_master;
    delete data.region_master;
    if (!data.region_name) {
      const { data: mappings } = await supabaseAdmin
        .from('user_region_mapping')
        .select('region_id')
        .eq('user_id', data.user_id)
        .limit(1);
      if (mappings && mappings.length > 0) {
        const { data: region } = await supabaseAdmin
          .from('region_master')
          .select('name')
          .eq('region_id', mappings[0].region_id)
          .maybeSingle();
        if (region) data.region_name = region.name;
      }
    }
    return data;
  }

  async update(userId, updateData) {
    const fields = {};

    Object.keys(updateData).forEach(key => {
      if (updateData[key] !== undefined) {
        fields[key] = updateData[key];
      }
    });

    if (Object.keys(fields).length === 0) return null;

    fields.updated_date = new Date();

    const { error } = await supabaseAdmin
      .from('user_master')
      .update(fields)
      .eq('user_id', userId);

    if (error) throw error;
    return true;
  }

  async getFullUserDetail(userId) {
    const { data, error } = await supabaseAdmin
      .from('user_master')
      .select(`*, role_master!left(name), zone_master!left(name), division_master!left(name), region_master!left(name)`)
      .eq('user_id', userId)
      .maybeSingle();
    if (error) throw error;
    if (!data) return null;

    const { data: trainMappings } = await supabaseAdmin
      .from('user_train_mapping')
      .select('train_id')
      .eq('user_id', userId);

    data.role_name = data.role_master?.name || null;
    data.zone_name = data.zone_master?.name || null;
    data.division_name = data.division_master?.name || null;
    data.region_name = data.region_master?.name || null;
    data.mapped_trains = (trainMappings || []).map(t => t.train_id).join(',');
    delete data.role_master;
    delete data.zone_master;
    delete data.division_master;
    delete data.region_master;

    return data;
  }
}

module.exports = new UserModel();
