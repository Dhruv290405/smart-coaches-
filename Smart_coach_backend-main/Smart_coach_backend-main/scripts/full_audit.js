const supabaseAdmin = require('../src/config/supabaseAdmin');
let acpSupabase;
try { acpSupabase = require('../src/config/supabaseAcp'); } catch(e) { acpSupabase = null; }
let supabaseOld;
try { supabaseOld = require('../src/config/supabaseOld'); } catch(e) { supabaseOld = null; }

async function audit() {
  const report = {};

  // ── 1. USERS ──
  const { data: users } = await supabaseAdmin.from('user_master').select(`
    user_id, email, role_id, zone_id, division_id, region_id,
    zone_master!left(name), division_master!left(name), region_master!left(name)
  `).in('email', ['danapur.ops@test.com', 'nagpur@test.com', 'admin@test.com']);
  report.users = (users || []).map(u => ({
    email: u.email, role_id: u.role_id,
    zone: u.zone_master?.name || null,
    division: u.division_master?.name || null,
    region: u.region_master?.name || null,
    zone_id: u.zone_id, division_id: u.division_id, region_id: u.region_id
  }));
  console.log('\n══════ 1. USER MAPPING ══════');
  console.table(report.users);

  // ── 2. COACHES_RAILWAY (Brake Binding RBAC source) ──
  const { data: crAll } = await supabaseAdmin.from('coaches_railway').select('*');
  report.coaches_railway = crAll || [];
  console.log('\n══════ 2. COACHES_RAILWAY (RBAC source) ══════');
  const byLoc = {};
  for (const r of report.coaches_railway) {
    const loc = r.Location || 'NULL';
    if (!byLoc[loc]) byLoc[loc] = [];
    byLoc[loc].push({ coach_no: r.coach_no, device_id: r.device_id, Train_no: r.Train_no, technical_id: r.technical_id });
  }
  for (const [loc, coaches] of Object.entries(byLoc)) {
    console.log(`  Location="${loc}": ${coaches.length} coaches → ${JSON.stringify(coaches.map(c=>c.coach_no))}`);
  }

  // ── 3. COACHES_HAMS (Hot Axle Section 1 HAMS) ──
  const { data: chAll } = await supabaseAdmin.from('coaches_hams').select('*');
  report.coaches_hams = chAll || [];
  console.log('\n══════ 3. COACHES_HAMS (HAMS Section 1 source) ══════');
  const hamsByLoc = {};
  for (const r of report.coaches_hams) {
    const loc = r.location || 'NULL';
    if (!hamsByLoc[loc]) hamsByLoc[loc] = [];
    hamsByLoc[loc].push({ actual_id: r.actual_id, technical_id: r.technical_id, coach_no: r.coach_no, device_id: r.device_id });
  }
  for (const [loc, items] of Object.entries(hamsByLoc)) {
    console.log(`  Location="${loc}": ${items.length} HAMS devices → ${JSON.stringify(items.map(i=>i.actual_id))}`);
  }

  // ── 4. SENSOR_CONFIG ──
  const { data: scAll } = await supabaseAdmin.from('sensor_config').select('sensor_config_id, location, tech_coach_no, train_no, status').limit(200);
  report.sensor_config_locations = [...new Set((scAll||[]).map(s => s.location))];
  console.log('\n══════ 4. SENSOR_CONFIG ══════');
  console.log(`  Total configs: ${(scAll||[]).length}`);
  console.log(`  Unique locations: ${JSON.stringify(report.sensor_config_locations)}`);
  console.log(`  Any with "Danapur": ${(scAll||[]).filter(s => (s.location||'').toLowerCase().includes('danapur')).length}`);
  console.log(`  Any with "Nagpur": ${(scAll||[]).filter(s => (s.location||'').toLowerCase().includes('nagpur')).length}`);

  // ── 5. HOT_AXLE_LOGS (Section 2) ──
  const { data: haLogs } = await supabaseAdmin.from('hot_axle_logs').select('device_id, coach_number, coach_type, train_no').limit(500);
  const haDevices = [...new Set((haLogs||[]).map(r => r.device_id))];
  const haCoaches = [...new Set((haLogs||[]).map(r => r.coach_number))];
  const haTrains = [...new Set((haLogs||[]).map(r => r.train_no))];
  console.log('\n══════ 5. HOT_AXLE_LOGS (Section 2) ══════');
  console.log(`  Total logs: ${(haLogs||[]).length}`);
  console.log(`  Unique device_ids: ${JSON.stringify(haDevices)}`);
  console.log(`  Unique coach_numbers: ${JSON.stringify(haCoaches)}`);
  console.log(`  Unique train_nos: ${JSON.stringify(haTrains)}`);

  // ── 6. HAMS_DATA (Section 1, Old Supabase) ──
  if (supabaseOld) {
    const { data: hamsData, error: hamsErr } = await supabaseOld.from('hams_data').select('master_id, device_id').limit(50);
    const hamsMasters = [...new Set((hamsData||[]).map(r => r.master_id))];
    const hamsDevices = [...new Set((hamsData||[]).map(r => r.device_id))];
    console.log('\n══════ 6. HAMS_DATA (Section 1, Old Supabase) ══════');
    console.log(`  Total rows (sample): ${(hamsData||[]).length}, Error: ${hamsErr?.message || 'none'}`);
    console.log(`  Unique master_ids: ${JSON.stringify(hamsMasters)}`);
    console.log(`  Unique device_ids: ${JSON.stringify(hamsDevices.slice(0,10))}`);
  } else {
    console.log('\n══════ 6. HAMS_DATA — Old Supabase NOT configured ══════');
  }

  // ── 7. PRESSURE_LOGS (BC Pressure) ──
  const { data: pLogs } = await supabaseAdmin.from('pressure_logs').select('device_id, coach_number, train_number').limit(200);
  const pCoaches = [...new Set((pLogs||[]).map(r => r.coach_number))];
  const pDevices = [...new Set((pLogs||[]).map(r => r.device_id))];
  console.log('\n══════ 7. PRESSURE_LOGS (BC Pressure) ══════');
  console.log(`  Total logs: ${(pLogs||[]).length}`);
  console.log(`  Unique coach_numbers: ${JSON.stringify(pCoaches)}`);
  console.log(`  Unique device_ids: ${JSON.stringify(pDevices)}`);

  // ── 8. ACP DATA (railway_acp_data, separate Supabase) ──
  if (acpSupabase) {
    const { data: acpData, error: acpErr } = await acpSupabase.from('railway_acp_data').select('loc_name, asset_name').eq('msg_type','METRICS').limit(200);
    const acpTrains = [...new Set((acpData||[]).map(r => r.loc_name))];
    const acpCoaches = [...new Set((acpData||[]).map(r => {
      const parts = (r.asset_name||'').split(' ');
      return parts.length >= 4 && parts[2]==='ACP' ? parts[1] : r.asset_name;
    }))];
    console.log('\n══════ 8. ACP DATA (railway_acp_data) ══════');
    console.log(`  Total rows: ${(acpData||[]).length}, Error: ${acpErr?.message || 'none'}`);
    console.log(`  Unique loc_names (trains): ${JSON.stringify(acpTrains)}`);
    console.log(`  Unique coach_nos (from asset_name): ${JSON.stringify(acpCoaches.slice(0,15))}`);
    console.log(`  Any with "Danapur" in loc_name: ${(acpData||[]).filter(r => (r.loc_name||'').toLowerCase().includes('danapur')).length}`);
    console.log(`  Any with "Nagpur" in loc_name: ${(acpData||[]).filter(r => (r.loc_name||'').toLowerCase().includes('nagpur')).length}`);
  } else {
    console.log('\n══════ 8. ACP DATA — ACP Supabase NOT configured ══════');
  }

  // ── 9. WLI_LOGS (Water Tank) ──
  const { data: wliLogs } = await supabaseAdmin.from('wli_logs').select('device_id, coach_name, coach_id').limit(50);
  console.log('\n══════ 9. WLI_LOGS (Water Tank) ══════');
  console.log(`  Total rows (sample): ${(wliLogs||[]).length}`);
  const wliCoaches = [...new Set((wliLogs||[]).map(r => r.coach_name))];
  console.log(`  Unique coach_names: ${JSON.stringify(wliCoaches.slice(0,10))}`);

  // ── 10. ODOUR_LOGS ──
  const { data: odourLogs } = await supabaseAdmin.from('odour_logs').select('device_id, coach_number, train_number').limit(50);
  console.log('\n══════ 10. ODOUR_LOGS ══════');
  console.log(`  Total rows (sample): ${(odourLogs||[]).length}`);
  const odourCoaches = [...new Set((odourLogs||[]).map(r => r.coach_number))];
  console.log(`  Unique coach_numbers: ${JSON.stringify(odourCoaches.slice(0,10))}`);

  // ── 11. FSDS_LOGS ──
  const { data: fsdsLogs } = await supabaseAdmin.from('fsds_logs').select('device_id, loc_name, asset_name').limit(50);
  console.log('\n══════ 11. FSDS_LOGS ══════');
  console.log(`  Total rows (sample): ${(fsdsLogs||[]).length}`);

  // ── 12. DIESEL ──
  const { data: dieselSensors } = await supabaseAdmin.from('sensor_config').select('sensor_config_id, sensor_id, location, tech_coach_no').eq('sensor_type_id', '2').limit(50);
  console.log('\n══════ 12. DIESEL SENSORS ══════');
  console.log(`  Found: ${(dieselSensors||[]).length}`);

  // ══════════════════════════════════════════════════
  // RBAC SIMULATION
  // ══════════════════════════════════════════════════
  console.log('\n\n╔══════════════════════════════════════════════════╗');
  console.log('║       RBAC SIMULATION — Per Division             ║');
  console.log('╚══════════════════════════════════════════════════╝');

  for (const user of report.users) {
    if (user.role_id === 1) continue; // skip admin

    const isAdmin = user.role_id === 1;
    const division = user.division || 'UNKNOWN';
    const region = user.region || null;
    const userLoc = region || division; // getUserLocation returns first: region > division > zone

    console.log(`\n┌─── User: ${user.email} (Division: ${division}, Region: ${region}, Zone: ${user.zone}) ───┐`);
    console.log(`│ getUserLocation() → "${userLoc}"`);

    // Simulate getAuthorizedCoachNumbers
    const matchingCR = (report.coaches_railway).filter(r => 
      (r.Location || '').toLowerCase() === userLoc.toLowerCase()
    );
    const authorizedCoaches = matchingCR.map(r => r.coach_no);
    console.log(`│ getAuthorizedCoachNumbers() → [${authorizedCoaches.join(', ')}] (${authorizedCoaches.length} coaches)`);

    // Module analysis
    console.log('│');
    console.log('│ ── MODULE ANALYSIS ──');

    // Brake Binding
    const bbData = matchingCR;
    console.log(`│ 🔧 Brake Binding: ${bbData.length > 0 ? '✅ HAS DATA' : '❌ NO DATA'} (${bbData.length} coaches in coaches_railway with Location="${userLoc}")`);

    // Hot Axle Section 1 (HAMS)
    const hamsForUser = (report.coaches_hams).filter(r => 
      (r.location || '').toLowerCase() === userLoc.toLowerCase()
    );
    console.log(`│ 🔥 Hot Axle Section 1 (HAMS): ${hamsForUser.length > 0 ? '✅ HAS DATA' : '❌ NO DATA'} (${hamsForUser.length} HAMS devices with location="${userLoc}")`);

    // Hot Axle Section 2 (hot_axle_logs)
    const haMatches = (haLogs||[]).filter(r => authorizedCoaches.includes(r.coach_number));
    const haModelBug = authorizedCoaches.length === 0; // empty array doesn't block!
    console.log(`│ 🔥 Hot Axle Section 2 (logs): coach_number match=${haMatches.length}, BUT model has empty-array bug=${haModelBug ? '⚠️ YES—returns ALL data' : 'No'}`);

    // BC Pressure
    const pMatches = (pLogs||[]).filter(r => authorizedCoaches.includes(r.coach_number));
    const pBlocked = authorizedCoaches.length === 0; // model correctly returns [] for empty
    console.log(`│ 🔵 BC Pressure: coach_number match=${pMatches.length}, empty-array handled=${pBlocked ? '✅ returns []' : 'N/A'}`);

    // ACP
    if (acpSupabase) {
      // ACP uses in-memory filter: logLoc.includes(uLoc) || uLoc.includes(logLoc)
      // getUserLocations returns [region, division, zone]
      const userLocs = [region, division, user.zone].filter(Boolean).map(l => l.toLowerCase());
      // Check getAcpLogs filter
      const acpLogsFiltered = true; // getAcpLogs does filter
      const acpSummaryFiltered = false; // getAcpSummary has NO filter!
      console.log(`│ ⚡ ACP getAcpLogs: RBAC filter applied=✅ (location match on train_location)`);
      console.log(`│ ⚡ ACP getAcpSummary: RBAC filter applied=❌ NO FILTER — returns ALL data to everyone!`);
      console.log(`│ ⚡ ACP getFilterOptions: RBAC filter applied=❌ NO FILTER`);
      console.log(`│ ⚡ ACP getCoachHistory: RBAC filter applied=❌ NO FILTER`);
    }

    // WLI (Water Tank)
    const wliMatches = (wliLogs||[]).filter(r => authorizedCoaches.includes(r.coach_name));
    const wliBlocked = authorizedCoaches.length === 0;
    console.log(`│ 💧 WLI (Water Tank): coach match=${wliMatches.length}, empty-array handled=${wliBlocked ? '✅ returns []' : 'N/A'}`);

    // Odour
    const odourMatches = (odourLogs||[]).filter(r => authorizedCoaches.includes(r.coach_number));
    console.log(`│ 🌬️ Odour: coach match=${odourMatches.length}`);

    // FSDS
    console.log(`│ 🔥 FSDS: NO RBAC filtering in controller (returns all data to everyone) ⚠️`);

    // Diesel
    console.log(`│ ⛽ Diesel: uses getAuthorizedCoachNumbers — will ${authorizedCoaches.length === 0 ? 'likely return empty or unfiltered' : 'filter properly'}`);

    console.log('│');

    // What SHOULD show vs what DOES show
    console.log('│ ── EXPECTED vs ACTUAL ──');
    if (division === 'Nagpur') {
      console.log('│ EXPECTED: Brake Binding (ng-...), Hot Axle Section 1 ONLY');
      console.log(`│ ACTUAL BUGS:`);
      console.log(`│   - ACP Summary returns ALL data (no filter) → ⚠️ Nagpur SEES ACP data it shouldn't`);
      console.log(`│   - Hot Axle Section 2 model doesn't block empty coaches → ⚠️ may see Section 2 data`);
      console.log(`│   - FSDS has no filter → ⚠️ may see FSDS data`);
    } else if (division === 'Danapur') {
      console.log('│ EXPECTED: ACP, Hot Axle Section 2, BC Pressure ONLY');
      console.log(`│ ACTUAL BUGS:`);
      console.log(`│   - coaches_railway has NO Danapur entries → getAuthorizedCoachNumbers=[]`);
      console.log(`│   - Hot Axle Section 2 model: empty array doesn't filter → ⚠️ sees ALL hot_axle_logs`);
      console.log(`│   - BC Pressure model: correctly returns [] for empty coaches ✅ (but means NO pressure data shown)`);
      console.log(`│   - ACP getAcpLogs: location filter blocks (VASP trains ≠ Danapur) → ❌ NO ACP shown`);
      console.log(`│   - ACP getAcpSummary: NO filter → ⚠️ sees ALL ACP data`);
      console.log(`│   - WLI/Odour/Diesel: correctly returns [] ✅ but also blocks legitimate data if any`);
      console.log(`│   - FSDS: no filter → ⚠️ sees ALL FSDS data`);
    }
    console.log('└' + '─'.repeat(70) + '┘');
  }

  // ══════════════════════════════════════════════════
  // BUG SUMMARY
  // ══════════════════════════════════════════════════
  console.log('\n\n╔══════════════════════════════════════════════════╗');
  console.log('║               BUG SUMMARY                        ║');
  console.log('╚══════════════════════════════════════════════════╝');
  console.log(`
BUG 1: coaches_railway has NO entries for "Danapur"
  → getAuthorizedCoachNumbers returns [] for Danapur users
  → All coach-based filtering either blocks everything or leaks everything
  → IMPACT: Danapur can't see BC Pressure, WLI returns empty

BUG 2: Hot Axle Model (hotAxle.model.js) - Empty array doesn't block
  → getData(): "if (authorizedCoaches && authorizedCoaches.length > 0)" — empty array bypasses filter
  → getLatestStatusForAllCoaches(): same bug
  → getHistoryData(): same bug  
  → IMPACT: Both Nagpur & Danapur see ALL hot_axle_logs data

BUG 3: ACP Controller - getAcpSummary has NO RBAC filtering
  → Returns ALL ACP summary data to any authenticated user
  → IMPACT: Nagpur sees all ACP summaries

BUG 4: ACP Controller - getFilterOptions, getFilteredData, getCoachHistory have NO RBAC
  → IMPACT: Any user can access any ACP data via these endpoints

BUG 5: ACP getAcpLogs location filter is mismatched
  → ACP loc_name = "VASP ACP Train X" — doesn't match "Danapur" or "Nagpur"
  → The filter logLoc.includes(uLoc) fails for all divisions
  → IMPACT: No division user sees ACP logs (but should for Danapur)

BUG 6: FSDS Controller - NO RBAC filtering at all
  → getData() returns all FSDS data to any user
  → IMPACT: All users see all FSDS data

BUG 7: Hot Axle getHistory HAMS path - No division check
  → Any user can fetch HAMS (Section 1) data by passing coachType=HAMS
  → IMPACT: Danapur users could access Nagpur HAMS data

BUG 8: Hot Axle getNewCompanyData - only checks region_name for "danapur"
  → Uses req.user.region_name which may be null or different from division_name
  → For Danapur user: region_name comes from region_master (id=138)
  → Nagpur user has region_id=null → falls through to HAMS path

FUNDAMENTAL ISSUE: 
  The coaches_railway table was designed for brake binding devices only.
  Using it as the universal RBAC filter for ALL modules is architecturally wrong.
  Each module's data uses different identifiers and location schemes.
  
  SOLUTION: Need a division-to-module mapping that directly controls which 
  modules each division can access, independent of coaches_railway.
`);
}

audit().catch(e => console.error('Audit failed:', e.message));
