const ExcelJS = require('exceljs');
const PDFDocument = require('pdfkit');
const supabaseAdmin = require('../config/supabaseAdmin');
const supabaseOld = require('../config/supabaseOld');
const supabaseAcp = require('../config/supabaseAcp');
const rbac = require('../utils/rbac');
const { sendTransactionalEmail, isConfigured } = require('../utils/emailService');

const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;

const MODULE_NAMES = {
  brake_binding: 'Brake Binding',
  hot_axle_section1: 'Hot Axle - HAMS',
  hot_axle_section2: 'Hot Axle - New Company',
  acp: 'ACP',
  odour: 'Bad Odour',
  bc_pressure: 'BC Pressure',
};

const REPORTABLE_MODULES = Object.keys(MODULE_NAMES);

function normalizeLocation(value) {
  return String(value == null ? '' : value).trim().toLowerCase().replace(/\s+/g, ' ');
}

function pickName(relation) {
  const row = Array.isArray(relation) ? relation[0] : relation;
  return row?.name || null;
}

function formatIST(value, withTime = true) {
  if (value == null || value === '') return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return String(value);
  const shifted = new Date(date.getTime() + IST_OFFSET_MS);
  const dd = String(shifted.getUTCDate()).padStart(2, '0');
  const mm = String(shifted.getUTCMonth() + 1).padStart(2, '0');
  const yyyy = shifted.getUTCFullYear();
  if (!withTime) return `${dd}/${mm}/${yyyy}`;
  const hh = String(shifted.getUTCHours()).padStart(2, '0');
  const mi = String(shifted.getUTCMinutes()).padStart(2, '0');
  const ss = String(shifted.getUTCSeconds()).padStart(2, '0');
  return `${dd}/${mm}/${yyyy} ${hh}:${mi}:${ss}`;
}

function describePeriod(start, end) {
  return {
    start,
    end,
    startIso: start.toISOString(),
    endIso: end.toISOString(),
    label: `${formatIST(start, false)} to ${formatIST(new Date(end.getTime() - 1000), false)}`,
    fileStamp: `${formatIST(start, false).split('/').reverse().join('')}_${formatIST(new Date(end.getTime() - 1000), false).split('/').reverse().join('')}`,
  };
}

function getPreviousWeekPeriod(now = new Date()) {
  const shifted = new Date(now.getTime() + IST_OFFSET_MS);
  const day = shifted.getUTCDay();
  const daysSinceMonday = (day + 6) % 7;
  const todayStartLocal = Date.UTC(
    shifted.getUTCFullYear(),
    shifted.getUTCMonth(),
    shifted.getUTCDate()
  );
  const currentMondayLocal = todayStartLocal - daysSinceMonday * DAY_MS;
  const startLocal = currentMondayLocal - 7 * DAY_MS;
  const start = new Date(startLocal - IST_OFFSET_MS);
  const end = new Date(currentMondayLocal - IST_OFFSET_MS);
  return describePeriod(start, end);
}

function getPeriodBefore(period) {
  return describePeriod(
    new Date(period.start.getTime() - 7 * DAY_MS),
    new Date(period.end.getTime() - 7 * DAY_MS)
  );
}

function formatNumber(value) {
  const number = Number(value);
  if (!Number.isFinite(number)) return '0';
  return number.toLocaleString('en-IN');
}

function percentChange(current, previous) {
  const currentValue = Number(current);
  const previousValue = Number(previous);
  if (!Number.isFinite(currentValue) || !Number.isFinite(previousValue)) return null;
  if (previousValue === 0) return currentValue === 0 ? 0 : null;
  return ((currentValue - previousValue) / previousValue) * 100;
}

function formatChange(current, previous) {
  const percent = percentChange(current, previous);
  if (percent == null) return Number(current) === 0 ? '0%' : 'new';
  return `${percent > 0 ? '+' : ''}${percent.toFixed(0)}%`;
}

function changeColor(current, previous) {
  const percent = percentChange(current, previous);
  if (percent == null) return '#b91c1c';
  if (percent > 0) return '#b91c1c';
  if (percent < 0) return '#047857';
  return '#6b7280';
}

function makeResult(key, { total = 0, alerts = 0, metrics = [], columns = [], rows = [], note = '' } = {}) {
  return {
    key,
    name: MODULE_NAMES[key] || key,
    total,
    alerts,
    metrics,
    columns,
    rows,
    note,
  };
}

function errorResult(key, error) {
  return makeResult(key, { note: `Could not generate: ${error.message || error}` });
}

function withTimeout(promise, ms = 30000) {
  let timer;
  const timeout = new Promise((_, reject) => {
    timer = setTimeout(() => reject(new Error('query timed out')), ms);
  });
  return Promise.race([promise, timeout]).finally(() => clearTimeout(timer));
}

async function countRows(client, table, applyFilters) {
  if (!client) throw new Error('data source is not configured');
  let query = client.from(table).select('*', { count: 'exact', head: true });
  query = applyFilters(query);
  const { count, error } = await query;
  if (error) throw error;
  return count || 0;
}

async function fetchRows(client, table, columns, applyFilters, orderColumn, limit) {
  if (!client) throw new Error('data source is not configured');
  let query = client.from(table).select(columns);
  query = applyFilters(query);
  const { data, error } = await query.order(orderColumn, { ascending: false }).limit(limit);
  if (error) throw error;
  return data || [];
}

async function safeCount(client, table, applyFilters) {
  try {
    return { value: await countRows(client, table, applyFilters), error: null };
  } catch (error) {
    return { value: 0, error: error.message };
  }
}

async function safeRows(client, table, columns, applyFilters, orderColumn, limit) {
  try {
    return { value: await fetchRows(client, table, columns, applyFilters, orderColumn, limit), error: null };
  } catch (error) {
    return { value: [], error: error.message };
  }
}

function maxAxleTemperature(row) {
  const values = ['a11_temp', 'a12_temp', 'a21_temp', 'a22_temp', 'a31_temp', 'a32_temp', 'a41_temp', 'a42_temp']
    .map((key) => Number(row[key]))
    .filter((value) => Number.isFinite(value) && value > -40);
  return values.length ? Math.max(...values) : null;
}

async function getLocationScope(location) {
  const rows = [];
  for (const client of [supabaseAdmin, supabaseOld]) {
    if (!client) continue;
    try {
      const { data, error } = await client
        .from('coaches_railway')
        .select('device_id,coach_no,Train_no,technical_id,Actual_id')
        .ilike('Location', location);
      if (error) throw error;
      rows.push(...(data || []));
    } catch (_) {}
  }

  const unique = (values) => [...new Set(values.filter((value) => value != null && String(value).trim() !== ''))];
  return {
    deviceIds: unique(rows.map((row) => row.device_id)),
    coachNos: unique(rows.map((row) => row.coach_no).map(String)),
    trainNos: unique(rows.map((row) => row.Train_no).map(String)),
    actualIds: unique(rows.map((row) => row.Actual_id)),
    coaches: rows.length,
  };
}

function getModulesForLocation(location) {
  const normalized = normalizeLocation(location);
  const mapKey = Object.keys(rbac.DIVISION_MODULE_MAP).find((key) => {
    const candidate = normalizeLocation(key);
    return normalized === candidate || normalized.startsWith(`${candidate} `) || normalized.startsWith(`${candidate}_`);
  });

  if (!mapKey) return ['brake_binding'];
  return rbac.DIVISION_MODULE_MAP[mapKey].filter((key) => REPORTABLE_MODULES.includes(key));
}

function getConfiguredRoleIds() {
  const raw = process.env.WEEKLY_REPORT_ROLE_IDS || '1,2,3,4';
  const ids = raw
    .split(',')
    .map((value) => parseInt(value.trim(), 10))
    .filter((value) => Number.isFinite(value));
  return ids.length ? [...new Set(ids)] : [1, 2, 3, 4];
}

function getExcludedEmails() {
  const raw = process.env.WEEKLY_REPORT_EXCLUDE_EMAILS || 'tester@example.com';
  return new Set(
    raw
      .split(',')
      .map((value) => value.trim().toLowerCase())
      .filter(Boolean)
  );
}

async function getReportLocations() {
  const { data, error } = await supabaseAdmin
    .from('user_master')
    .select(`
      user_id, email, first_name, role_id,
      division_master!left(name),
      region_master!left(name),
      zone_master!left(name)
    `)
    .eq('approval_status', 'Approved')
    .in('role_id', getConfiguredRoleIds());

  if (error) throw error;

  const excluded = getExcludedEmails();
  const grouped = new Map();

  for (const user of data || []) {
    const email = String(user.email || '').trim().toLowerCase();
    if (!email || !email.includes('@') || excluded.has(email)) continue;

    const location =
      pickName(user.division_master) ||
      pickName(user.region_master) ||
      pickName(user.zone_master);
    if (!location) continue;

    const key = normalizeLocation(location);
    if (!grouped.has(key)) {
      grouped.set(key, {
        location,
        emails: new Set(),
        modules: getModulesForLocation(location),
      });
    }
    grouped.get(key).emails.add(email);
  }

  return [...grouped.values()]
    .filter((entry) => entry.modules.length > 0)
    .map((entry) => ({ ...entry, emails: [...entry.emails] }))
    .sort((a, b) => a.location.localeCompare(b.location));
}

async function buildBrakeBinding(ctx) {
  if (!ctx.scope.deviceIds.length) {
    return makeResult('brake_binding', { note: 'No coaches are registered for this location.' });
  }

  const apply = (query) =>
    query
      .in('device_id', ctx.scope.deviceIds)
      .gte('timestamp', ctx.period.startIso)
      .lt('timestamp', ctx.period.endIso);

  const [readings, faults, faultRows] = await Promise.all([
    safeCount(supabaseOld, 'bpc_pressure', apply),
    safeCount(supabaseOld, 'brake_fault_event', apply),
    safeRows(
      supabaseOld,
      'brake_fault_event',
      'timestamp,coach_no,device_id,fault_name,fault_duration',
      apply,
      'timestamp',
      25
    ),
  ]);

  const notes = [];
  if (readings.error) notes.push(`Readings: ${readings.error}`);
  if (faults.error) notes.push(`Faults: ${faults.error}`);

  return makeResult('brake_binding', {
    total: readings.value,
    alerts: faults.value,
    metrics: [
      { label: 'Readings', value: formatNumber(readings.value) },
      { label: 'Fault events', value: formatNumber(faults.value) },
      { label: 'Coaches monitored', value: formatNumber(ctx.scope.deviceIds.length) },
    ],
    columns: ['Timestamp', 'Coach', 'Device', 'Fault', 'Duration'],
    rows: faultRows.value.map((row) => [
      formatIST(row.timestamp),
      row.coach_no || '',
      row.device_id || '',
      row.fault_name || '',
      row.fault_duration == null ? '' : `${row.fault_duration}s`,
    ]),
    note: notes.join('; '),
  });
}

async function buildHotAxleSection1(ctx) {
  const apply = (query) =>
    query
      .eq('master_id', 'HAMS-M1-001')
      .gte('created_at', ctx.period.startIso)
      .lt('created_at', ctx.period.endIso);

  const [total, abnormal, sample] = await Promise.all([
    safeCount(supabaseOld, 'hams_data', apply),
    safeCount(supabaseOld, 'hams_data', (query) => apply(query).neq('temp_state', 'Normal')),
    safeRows(
      supabaseOld,
      'hams_data',
      'created_at,device_id,temperature,temp_state,battery_status',
      apply,
      'created_at',
      2000
    ),
  ]);

  const temperatures = sample.value
    .map((row) => Number(row.temperature))
    .filter((value) => Number.isFinite(value));
  const maxTemperature = temperatures.length ? Math.max(...temperatures) : null;

  return makeResult('hot_axle_section1', {
    total: total.value,
    alerts: abnormal.value,
    metrics: [
      { label: 'Readings', value: formatNumber(total.value) },
      { label: 'Temperature alerts', value: formatNumber(abnormal.value) },
      { label: 'Max temperature', value: maxTemperature == null ? 'N/A' : `${maxTemperature.toFixed(1)} C` },
    ],
    columns: ['Timestamp', 'Device', 'Temperature', 'State', 'Battery'],
    rows: sample.value.slice(0, 25).map((row) => [
      formatIST(row.created_at),
      row.device_id || '',
      row.temperature == null ? '' : `${Number(row.temperature).toFixed(1)} C`,
      row.temp_state || '',
      row.battery_status || '',
    ]),
    note: abnormal.error ? `Alerts: ${abnormal.error}` : '',
  });
}

async function buildHotAxleSection2(ctx) {
  const apply = (query) =>
    query.gte('timestamp', ctx.period.startIso).lt('timestamp', ctx.period.endIso);

  const [total, critical, warning, sample] = await Promise.all([
    safeCount(supabaseAdmin, 'hot_axle_logs', apply),
    safeCount(supabaseAdmin, 'hot_axle_logs', (query) => apply(query).eq('alert_status', 'Critical')),
    safeCount(supabaseAdmin, 'hot_axle_logs', (query) => apply(query).eq('alert_status', 'Warning')),
    safeRows(
      supabaseAdmin,
      'hot_axle_logs',
      'timestamp,coach_number,device_id,train_no,alert_status,a11_temp,a12_temp,a21_temp,a22_temp,a31_temp,a32_temp,a41_temp,a42_temp',
      apply,
      'timestamp',
      2000
    ),
  ]);

  const alertRows = sample.value
    .filter((row) => row.alert_status && row.alert_status !== 'Good')
    .slice(0, 25);
  const temperatures = sample.value
    .map(maxAxleTemperature)
    .filter((value) => value != null);
  const maxTemperature = temperatures.length ? Math.max(...temperatures) : null;

  return makeResult('hot_axle_section2', {
    total: total.value,
    alerts: critical.value + warning.value,
    metrics: [
      { label: 'Readings', value: formatNumber(total.value) },
      { label: 'Critical alerts', value: formatNumber(critical.value) },
      { label: 'Warnings', value: formatNumber(warning.value) },
      { label: 'Max axle temperature', value: maxTemperature == null ? 'N/A' : `${maxTemperature.toFixed(1)} C` },
    ],
    columns: ['Timestamp', 'Coach', 'Device', 'Train', 'Status', 'Max temp'],
    rows: alertRows.map((row) => {
      const maxTemperature = maxAxleTemperature(row);
      return [
        formatIST(row.timestamp),
        row.coach_number || '',
        row.device_id || '',
        row.train_no || '',
        row.alert_status || '',
        maxTemperature == null ? '' : `${maxTemperature.toFixed(1)} C`,
      ];
    }),
    note: sample.error ? `Readings: ${sample.error}` : '',
  });
}

async function buildAcp(ctx) {
  const apply = (query) =>
    query
      .eq('msg_type', 'METRICS')
      .gte('created_at', ctx.period.startIso)
      .lt('created_at', ctx.period.endIso);

  const [total, critical, rows] = await Promise.all([
    safeCount(supabaseAcp, 'railway_acp_data', apply),
    safeCount(supabaseAcp, 'railway_acp_data', (query) => apply(query).gt('count_value', 0)),
    safeRows(
      supabaseAcp,
      'railway_acp_data',
      'created_at,metric_timestamp,loc_name,asset_name,coach_no,count_value,device_id',
      (query) => apply(query).gt('count_value', 0),
      'created_at',
      25
    ),
  ]);

  return makeResult('acp', {
    total: total.value,
    alerts: critical.value,
    metrics: [
      { label: 'Metrics received', value: formatNumber(total.value) },
      { label: 'ACP obstructions', value: formatNumber(critical.value) },
    ],
    columns: ['Timestamp', 'Train', 'Asset', 'Coach', 'Count', 'Device'],
    rows: rows.value.map((row) => [
      formatIST(row.metric_timestamp || row.created_at),
      row.loc_name || '',
      row.asset_name || '',
      row.coach_no || '',
      row.count_value == null ? '' : String(row.count_value),
      row.device_id || '',
    ]),
    note: rows.error ? `Alerts: ${rows.error}` : '',
  });
}

async function buildOdour(ctx) {
  const apply = (query) =>
    query
      .ilike('location', ctx.location)
      .gte('timestamp', ctx.period.startIso)
      .lt('timestamp', ctx.period.endIso);

  const alertFilter = (query) =>
    apply(query).or('voc_index.gte.800,h2s_ppm.gt.0.05,nh3_ppm.gt.0.2');

  const [total, alerts, registered, rows] = await Promise.all([
    safeCount(supabaseAcp, 'bad_odour_data', apply),
    safeCount(supabaseAcp, 'bad_odour_data', alertFilter),
    safeCount(supabaseAcp, 'coaches_Bad_Odour', (query) => query.ilike('location', ctx.location)),
    safeRows(
      supabaseAcp,
      'bad_odour_data',
      'timestamp,device_ID,Coach_ID,Coach_no,Train_No,voc_index,h2s_ppm,nh3_ppm,Status_VOC,Bad_Odour_generation',
      alertFilter,
      'timestamp',
      25
    ),
  ]);

  return makeResult('odour', {
    total: total.value,
    alerts: alerts.value,
    metrics: [
      { label: 'Readings', value: formatNumber(total.value) },
      { label: 'Bad odour alerts', value: formatNumber(alerts.value) },
      { label: 'Registered coaches', value: formatNumber(registered.value) },
    ],
    columns: ['Timestamp', 'Device', 'Coach', 'Train', 'VOC', 'H2S', 'NH3', 'Status'],
    rows: rows.value.map((row) => [
      formatIST(row.timestamp),
      row.device_ID || '',
      row.Coach_ID || row.Coach_no || '',
      row.Train_No || '',
      row.voc_index == null ? '' : String(row.voc_index),
      row.h2s_ppm == null ? '' : String(row.h2s_ppm),
      row.nh3_ppm == null ? '' : String(row.nh3_ppm),
      row.Bad_Odour_generation || row.Status_VOC || '',
    ]),
    note: rows.error ? `Alerts: ${rows.error}` : '',
  });
}

async function buildBcPressure(ctx) {
  const apply = (query) =>
    query.gte('timestamp', ctx.period.startIso).lt('timestamp', ctx.period.endIso);

  const [total, faults, rows] = await Promise.all([
    safeCount(supabaseAdmin, 'pressure_logs', apply),
    safeCount(supabaseAdmin, 'pressure_logs', (query) => apply(query).not('brake_fault', 'is', null)),
    safeRows(
      supabaseAdmin,
      'pressure_logs',
      'timestamp,coach_number,train_number,brake_status,brake_fault,brake_pressure as bp',
      apply,
      'timestamp',
      25
    ),
  ]);

  return makeResult('bc_pressure', {
    total: total.value,
    alerts: faults.value,
    metrics: [
      { label: 'Readings', value: formatNumber(total.value) },
      { label: 'Fault events', value: formatNumber(faults.value) },
    ],
    columns: ['Timestamp', 'Coach', 'Train', 'Status', 'Fault', 'BP'],
    rows: rows.value.map((row) => [
      formatIST(row.timestamp),
      row.coach_number || '',
      row.train_number || '',
      row.brake_status || '',
      row.brake_fault || '',
      row.bp == null ? '' : String(row.bp),
    ]),
    note: faults.error ? `Faults: ${faults.error}` : '',
  });
}

const BUILDERS = {
  brake_binding: buildBrakeBinding,
  hot_axle_section1: buildHotAxleSection1,
  hot_axle_section2: buildHotAxleSection2,
  acp: buildAcp,
  odour: buildOdour,
  bc_pressure: buildBcPressure,
};

async function buildLocationReport(location, modules, period, options = {}) {
  const includeComparison = options.includeComparison !== false;
  const scope = await getLocationScope(location);
  const previousPeriod = includeComparison ? getPeriodBefore(period) : null;
  const previousByKey = new Map();

  if (previousPeriod) {
    const previousResults = await Promise.all(modules.map(async (key) => {
      const builder = BUILDERS[key];
      if (!builder) return [key, null];
      try {
        return [key, await withTimeout(builder({ location, period: previousPeriod, scope }), 45000)];
      } catch (_) {
        return [key, null];
      }
    }));
    previousResults.forEach(([key, result]) => previousByKey.set(key, result));
  }

  const results = [];

  for (const key of modules) {
    const builder = BUILDERS[key];
    if (!builder) continue;
    let result;
    try {
      result = await withTimeout(builder({ location, period, scope }), 45000);
    } catch (error) {
      result = errorResult(key, error);
    }

    const previous = previousByKey.get(key);
    if (previous) {
      result.comparison = {
        period: previousPeriod.label,
        total: previous.total,
        alerts: previous.alerts,
        totalChangePercent: percentChange(result.total, previous.total),
        alertChangePercent: percentChange(result.alerts, previous.alerts),
      };
    }
    if (!result.note && result.total === 0 && result.alerts === 0) {
      result.note = 'No data in this period.';
    }
    results.push(result);
  }

  return {
    location,
    period,
    previousPeriod,
    generatedAt: new Date(),
    modules: results,
  };
}

function summarizeReport(report) {
  return {
    location: report.location,
    period: report.period.label,
    previousPeriod: report.previousPeriod ? report.previousPeriod.label : null,
    generatedAt: report.generatedAt.toISOString(),
    modules: report.modules.map((module) => ({
      key: module.key,
      name: module.name,
      total: module.total,
      alerts: module.alerts,
      comparison: module.comparison || null,
      note: module.note || '',
    })),
  };
}

function escapeHtml(value) {
  return String(value == null ? '' : value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function buildEmailHtml(report) {
  const totalRecords = report.modules.reduce((sum, module) => sum + module.total, 0);
  const totalAlerts = report.modules.reduce((sum, module) => sum + module.alerts, 0);
  const previousAlerts = report.modules.reduce(
    (sum, module) => sum + (module.comparison ? module.comparison.alerts : 0),
    0
  );
  const rows = report.modules
    .map((module) => {
      const previous = module.comparison
        ? formatNumber(module.comparison.alerts)
        : '&mdash;';
      const change = module.comparison
        ? `<span style="color:${changeColor(module.alerts, module.comparison.alerts)};font-weight:bold;">${formatChange(module.alerts, module.comparison.alerts)}</span>`
        : '&mdash;';
      return `
      <tr>
        <td style="padding:8px;border-bottom:1px solid #e5e7eb;">${escapeHtml(module.name)}</td>
        <td style="padding:8px;border-bottom:1px solid #e5e7eb;text-align:right;">${formatNumber(module.total)}</td>
        <td style="padding:8px;border-bottom:1px solid #e5e7eb;text-align:right;">${formatNumber(module.alerts)}</td>
        <td style="padding:8px;border-bottom:1px solid #e5e7eb;text-align:right;">${previous}</td>
        <td style="padding:8px;border-bottom:1px solid #e5e7eb;text-align:right;">${change}</td>
      </tr>`;
    })
    .join('');

  const alertComparison = previousAlerts > 0 || totalAlerts > 0
    ? `<div style="font-size:11px;color:#991b1b;margin-top:4px;">${formatNumber(previousAlerts)} last week (${formatChange(totalAlerts, previousAlerts)})</div>`
    : '';

  return `
    <div style="font-family:Arial,sans-serif;color:#111827;max-width:720px;margin:0 auto;">
      <h2 style="margin:0 0 4px;color:#0f172a;">Smart Coach Weekly Report</h2>
      <p style="margin:0 0 4px;font-size:14px;"><strong>Location:</strong> ${escapeHtml(report.location)}</p>
      <p style="margin:0 0 18px;font-size:14px;"><strong>Period:</strong> ${escapeHtml(report.period.label)}${report.previousPeriod ? ` (compared with ${escapeHtml(report.previousPeriod.label)})` : ''}</p>
      <div style="display:flex;gap:12px;margin-bottom:18px;">
        <div style="flex:1;background:#eff6ff;border-radius:8px;padding:12px;">
          <div style="font-size:12px;color:#1d4ed8;">Total records</div>
          <div style="font-size:22px;font-weight:bold;color:#1e3a8a;">${formatNumber(totalRecords)}</div>
        </div>
        <div style="flex:1;background:#fef2f2;border-radius:8px;padding:12px;">
          <div style="font-size:12px;color:#b91c1c;">Total alerts / faults</div>
          <div style="font-size:22px;font-weight:bold;color:#7f1d1d;">${formatNumber(totalAlerts)}</div>
          ${alertComparison}
        </div>
      </div>
      <table style="width:100%;border-collapse:collapse;font-size:14px;">
        <thead>
          <tr style="background:#f3f4f6;text-align:left;">
            <th style="padding:8px;border-bottom:1px solid #d1d5db;">Module</th>
            <th style="padding:8px;border-bottom:1px solid #d1d5db;text-align:right;">Records</th>
            <th style="padding:8px;border-bottom:1px solid #d1d5db;text-align:right;">Alerts</th>
            <th style="padding:8px;border-bottom:1px solid #d1d5db;text-align:right;">Prev alerts</th>
            <th style="padding:8px;border-bottom:1px solid #d1d5db;text-align:right;">Change</th>
          </tr>
        </thead>
        <tbody>${rows}</tbody>
      </table>
      <p style="font-size:13px;color:#4b5563;margin-top:18px;">
        Detailed Excel and PDF reports are attached. Only data for ${escapeHtml(report.location)} is included.
      </p>
      <p style="font-size:12px;color:#9ca3af;margin-top:24px;">Generated by Smart Coach on ${formatIST(report.generatedAt)} IST.</p>
    </div>
  `;
}

function safeFileName(value) {
  return String(value || 'location').replace(/[^A-Za-z0-9._-]+/g, '_');
}

async function generateExcelBuffer(report) {
  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'Smart Coach';
  workbook.created = report.generatedAt;

  const summary = workbook.addWorksheet('Summary');
  summary.columns = [
    { width: 28 },
    { width: 14 },
    { width: 12 },
    { width: 14 },
    { width: 12 },
    { width: 14 },
    { width: 14 },
    { width: 42 },
  ];
  summary.mergeCells('A1:H1');
  summary.getCell('A1').value = 'Smart Coach Weekly Report';
  summary.getCell('A1').font = { size: 18, bold: true, color: { argb: 'FF0F172A' } };
  summary.addRow([]);
  summary.addRow(['Location', report.location]);
  summary.addRow(['Period', report.period.label]);
  if (report.previousPeriod) summary.addRow(['Compared with', report.previousPeriod.label]);
  summary.addRow(['Generated', `${formatIST(report.generatedAt)} IST`]);
  summary.addRow([]);
  summary.addRow(['Module', 'Records', 'Alerts', 'Prev records', 'Prev alerts', 'Record change', 'Alert change', 'Note']);

  const summaryHeader = summary.lastRow;
  const summaryHeaderNumber = summaryHeader.number;
  summaryHeader.font = { bold: true, color: { argb: 'FFFFFFFF' } };
  summaryHeader.eachCell((cell) => {
    cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1E3A8A' } };
  });

  report.modules.forEach((module) => {
    const comparison = module.comparison || {};
    summary.addRow([
      module.name,
      module.total,
      module.alerts,
      comparison.total == null ? '' : comparison.total,
      comparison.alerts == null ? '' : comparison.alerts,
      module.comparison ? formatChange(module.total, comparison.total) : '',
      module.comparison ? formatChange(module.alerts, comparison.alerts) : '',
      module.note || '',
    ]);
  });
  summary.eachRow((row, rowNumber) => {
    if (rowNumber > summaryHeaderNumber) {
      row.alignment = { vertical: 'top', wrapText: true };
    }
  });

  for (const module of report.modules) {
    const sheetName = module.name.replace(/[\\/*?:[\]]/g, '').slice(0, 31) || module.key;
    const sheet = workbook.addWorksheet(sheetName);
    sheet.columns = (module.columns.length ? module.columns : ['Info']).map((column, index) => ({
      width: Math.max(14, Math.min(42, String(column).length + 8 + (index === 0 ? 6 : 0))),
    }));

    sheet.mergeCells(1, 1, 1, Math.max(1, module.columns.length || 1));
    sheet.getCell(1, 1).value = `${module.name} - ${report.location}`;
    sheet.getCell(1, 1).font = { size: 14, bold: true, color: { argb: 'FF1E3A8A' } };
    sheet.addRow([]);
    sheet.addRow(['Period', report.period.label]);
    module.metrics.forEach((metric) => sheet.addRow([metric.label, metric.value]));
    if (module.comparison) {
      sheet.addRow(['Previous period', module.comparison.period]);
      sheet.addRow(['Previous records', module.comparison.total]);
      sheet.addRow(['Previous alerts', module.comparison.alerts]);
      sheet.addRow(['Record change', formatChange(module.total, module.comparison.total)]);
      sheet.addRow(['Alert change', formatChange(module.alerts, module.comparison.alerts)]);
    }
    if (module.note) sheet.addRow(['Note', module.note]);
    sheet.addRow([]);

    const headerRow = sheet.addRow(module.columns);
    headerRow.font = { bold: true, color: { argb: 'FFFFFFFF' } };
    headerRow.eachCell((cell) => {
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1E3A8A' } };
      cell.alignment = { vertical: 'middle', wrapText: true };
    });

    if (module.rows.length === 0) {
      sheet.addRow(['No matching records in this period']);
    } else {
      module.rows.forEach((row) => sheet.addRow(row));
    }

    sheet.eachRow((row, rowNumber) => {
      if (rowNumber > 5) {
        row.alignment = { vertical: 'top', wrapText: true };
      }
    });
    sheet.views = [{ state: 'frozen', ySplit: Math.min(headerRow.number, 10) }];
  }

  const buffer = await workbook.xlsx.writeBuffer();
  return Buffer.from(buffer);
}

function drawPdfTable(doc, columns, rows, widths, options = {}) {
  const left = doc.page.margins.left;
  const bottom = doc.page.height - doc.page.margins.bottom - 24;
  const rowHeight = options.rowHeight || 16;
  const fontSize = options.fontSize || 7;
  const maxRows = options.maxRows || rows.length;

  const drawRow = (values, isHeader = false) => {
    if (doc.y + rowHeight > bottom) doc.addPage();
    const y = doc.y;
    let x = left;
    const height = isHeader ? 18 : rowHeight;

    if (isHeader) {
      doc.save().rect(left, y, widths.reduce((sum, width) => sum + width, 0), height).fill('#1E3A8A').restore();
    } else if (Math.round((y - doc.page.margins.top) / rowHeight) % 2 === 0) {
      doc.save().rect(left, y, widths.reduce((sum, width) => sum + width, 0), height).fill('#F8FAFC').restore();
    }

    values.forEach((value, index) => {
      doc
        .font(isHeader ? 'Helvetica-Bold' : 'Helvetica')
        .fontSize(fontSize)
        .fillColor(isHeader ? '#FFFFFF' : '#111827')
        .text(String(value == null ? '' : value), x + 3, y + 4, {
          width: widths[index] - 6,
          height: height - 5,
          ellipsis: true,
          lineBreak: false,
        });
      x += widths[index];
    });

    doc
      .strokeColor('#D1D5DB')
      .lineWidth(0.4)
      .moveTo(left, y + height)
      .lineTo(left + widths.reduce((sum, width) => sum + width, 0), y + height)
      .stroke();
    doc.y = y + height;
  };

  drawRow(columns, true);
  rows.slice(0, maxRows).forEach((row) => drawRow(row));
}

async function generatePdfBuffer(report) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({
      size: 'A4',
      layout: 'landscape',
      margins: { top: 34, bottom: 34, left: 34, right: 34 },
      bufferPages: true,
      info: {
        Title: `Smart Coach Weekly Report - ${report.location}`,
        Author: 'Smart Coach',
      },
    });

    const chunks = [];
    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    const pageWidth = doc.page.width - doc.page.margins.left - doc.page.margins.right;

    doc.font('Helvetica-Bold').fontSize(20).fillColor('#0F172A').text('Smart Coach Weekly Report', { align: 'center' });
    doc.moveDown(0.4);
    doc.font('Helvetica').fontSize(11).fillColor('#374151').text(`Location: ${report.location}`, { align: 'center' });
    doc.text(`Period: ${report.period.label}`, { align: 'center' });
    if (report.previousPeriod) doc.text(`Compared with: ${report.previousPeriod.label}`, { align: 'center' });
    doc.text(`Generated: ${formatIST(report.generatedAt)} IST`, { align: 'center' });
    doc.moveDown(1);

    const summaryWidths = [190, 90, 80, 80, Math.max(70, pageWidth - 440)];
    drawPdfTable(
      doc,
      ['Module', 'Records', 'Alerts', 'Prev alerts', 'Change'],
      report.modules.map((module) => [
        module.name,
        formatNumber(module.total),
        formatNumber(module.alerts),
        module.comparison ? formatNumber(module.comparison.alerts) : '-',
        module.comparison
          ? `${formatChange(module.alerts, module.comparison.alerts)}${module.note ? ` (${module.note})` : ''}`
          : (module.note || '-'),
      ]),
      summaryWidths,
      { rowHeight: 18, fontSize: 8 }
    );

    for (const module of report.modules) {
      if (doc.y > doc.page.height - doc.page.margins.bottom - 150) doc.addPage();
      doc.moveDown(1);
      doc.font('Helvetica-Bold').fontSize(13).fillColor('#1E3A8A').text(module.name);
      doc.moveDown(0.25);
      doc.font('Helvetica').fontSize(9).fillColor('#374151');
      module.metrics.forEach((metric) => {
        doc.text(`${metric.label}: ${metric.value}`);
      });
      if (module.comparison) {
        doc.text(`Previous week: ${formatNumber(module.comparison.total)} records, ${formatNumber(module.comparison.alerts)} alerts`);
        doc.text(`Change: ${formatChange(module.total, module.comparison.total)} records, ${formatChange(module.alerts, module.comparison.alerts)} alerts`);
      }
      if (module.note) doc.text(`Note: ${module.note}`);
      doc.moveDown(0.35);

      if (module.columns.length && module.rows.length) {
        const visibleColumns = module.columns.slice(0, 6);
        const visibleRows = module.rows.map((row) => row.slice(0, 6));
        const width = Math.floor(pageWidth / visibleColumns.length);
        drawPdfTable(
          doc,
          visibleColumns,
          visibleRows,
          visibleColumns.map(() => width),
          { rowHeight: 16, fontSize: 7, maxRows: 12 }
        );
        if (module.rows.length > 12) {
          doc.font('Helvetica-Oblique').fontSize(8).fillColor('#6B7280').text(`Showing latest 12 of ${module.rows.length} alert records in PDF. Full details are in the Excel attachment.`);
        }
      } else {
        doc.font('Helvetica-Oblique').fontSize(9).fillColor('#6B7280').text('No matching records for this period.');
      }
    }

    const range = doc.bufferedPageRange();
    for (let index = 0; index < range.count; index++) {
      doc.switchToPage(range.start + index);
      doc
        .font('Helvetica')
        .fontSize(7)
        .fillColor('#9CA3AF')
        .text(
          `Page ${index + 1} of ${range.count}`,
          doc.page.margins.left,
          doc.page.height - doc.page.margins.bottom + 10,
          { width: pageWidth, align: 'right', lineBreak: false }
        );
    }

    doc.end();
  });
}

function buildAttachments(report) {
  const stamp = safeFileName(report.period.fileStamp || 'week');
  const location = safeFileName(report.location);
  return Promise.all([
    generateExcelBuffer(report),
    generatePdfBuffer(report),
  ]).then(([excel, pdf]) => [
    { name: `weekly_report_${location}_${stamp}.xlsx`, content: excel },
    { name: `weekly_report_${location}_${stamp}.pdf`, content: pdf },
  ]);
}

async function sendWeeklyReports(options = {}) {
  if (!options.dryRun && !isConfigured()) {
    return { sent: 0, skipped: 'email_not_configured', results: [] };
  }

  const period = options.period || getPreviousWeekPeriod();
  const locations = await getReportLocations();
  const requestedLocation = options.location ? normalizeLocation(options.location) : null;
  const requestedEmails = Array.isArray(options.emails)
    ? options.emails.map((email) => String(email).trim().toLowerCase()).filter((email) => email.includes('@'))
    : null;

  let targets = locations;
  if (requestedLocation) {
    const found = locations.find((entry) => normalizeLocation(entry.location) === requestedLocation);
    if (found) {
      targets = [{ ...found, emails: requestedEmails || found.emails }];
    } else {
      targets = [{
        location: options.location,
        emails: requestedEmails || [],
        modules: getModulesForLocation(options.location),
      }];
    }
  }

  const results = [];
  let sent = 0;

  for (const target of targets) {
    let report;
    try {
      report = await buildLocationReport(target.location, target.modules, period);
    } catch (error) {
      results.push({ location: target.location, error: error.message });
      continue;
    }

    if (options.dryRun) {
      results.push({ ...summarizeReport(report), emails: target.emails });
      continue;
    }

    if (!target.emails.length) {
      results.push({ location: target.location, skipped: 'no_recipients' });
      continue;
    }

    let attachments;
    try {
      attachments = await buildAttachments(report);
    } catch (error) {
      results.push({ location: target.location, error: `attachment generation failed: ${error.message}` });
      continue;
    }

    const subject = `[Smart Coach] Weekly report - ${target.location} - ${report.period.label}`;
    const html = buildEmailHtml(report);
    const delivered = [];
    const failed = [];

    for (const email of target.emails) {
      try {
        await sendTransactionalEmail(email, subject, html, { attachments });
        delivered.push(email);
        sent++;
      } catch (error) {
        failed.push({ email, error: error.message });
      }
    }

    results.push({
      location: target.location,
      delivered,
      failed,
      modules: report.modules.map((module) => module.key),
    });
  }

  return { sent, period: period.label, results };
}

function startWeeklyReportScheduler() {
  if (String(process.env.WEEKLY_REPORT_ENABLED || 'true').toLowerCase() === 'false') {
    return;
  }

  const day = parseInt(process.env.WEEKLY_REPORT_DAY || '1', 10);
  const hour = parseInt(process.env.WEEKLY_REPORT_HOUR || '9', 10);
  const minute = parseInt(process.env.WEEKLY_REPORT_MINUTE || '0', 10);
  const windowMinutes = Math.max(1, parseInt(process.env.WEEKLY_REPORT_WINDOW_MINUTES || '14', 10));
  let lastRunKey = null;

  const tick = async () => {
    try {
      const now = new Date();
      const shifted = new Date(now.getTime() + IST_OFFSET_MS);
      const currentDay = shifted.getUTCDay();
      const currentHour = shifted.getUTCHours();
      const currentMinute = shifted.getUTCMinutes();
      const runKey = `${shifted.getUTCFullYear()}-${shifted.getUTCMonth()}-${shifted.getUTCDate()}`;

      if (currentDay !== day || currentHour !== hour || currentMinute < minute || currentMinute > minute + windowMinutes) return;
      if (lastRunKey === runKey) return;

      lastRunKey = runKey;
      console.log('[WEEKLY REPORT] Starting scheduled report run');
      const result = await sendWeeklyReports();
      console.log('[WEEKLY REPORT] Run complete:', JSON.stringify(result));
    } catch (error) {
      console.error('[WEEKLY REPORT] Scheduled run failed:', error.message);
    }
  };

  tick();
  const timer = setInterval(tick, 60 * 1000);
  if (timer.unref) timer.unref();
  console.log(`[WEEKLY REPORT] Scheduler enabled for day=${day} ${hour}:${String(minute).padStart(2, '0')} IST`);
}

module.exports = {
  getPreviousWeekPeriod,
  getPeriodBefore,
  getReportLocations,
  getModulesForLocation,
  buildLocationReport,
  generateExcelBuffer,
  generatePdfBuffer,
  sendWeeklyReports,
  startWeeklyReportScheduler,
};
