# Project Architecture Reference

## 3 Supabase Projects

| Ref | Project ID | URL Pattern | Env Var | Purpose | Key Tables |
|---|---|---|---|---|---|
| **Project 1** (supabaseAdmin) | `zfzpjlxbhvsofhbcoyxr` | `https://zfzpjlxbhvsofhbcoyxr.supabase.co` | `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | Primary app DB | `user_master`, `coaches_railway`, `division_master`, `coaches_hams`, `bpc_pressure` (empty), `pressure_logs`, `hams_data` (historical), `event_publish` (old data), `hot_axle_logs` |
| **Project 2** (supabaseOld) | `ajikchaxkmxcyuecqmce` | `https://ajikchaxkmxcyuecqmce.supabase.co` | `OLD_SUPABASE_URL`, `OLD_SUPABASE_SERVICE_ROLE_KEY` | Brake Binding LIVE | `event_publish` (LIVE), `brake_fault_event` (LIVE), `coaches_railway`, `hams_data` (LIVE), `bpc_pressure` (MUST CREATE) |
| **Project 3** (supabaseAcp) | `qcycuwfohxmdatrtawlw` | `https://qcycuwfohxmdatrtawlw.supabase.co` | `ACP_SUPABASE_URL`, `ACP_SUPABASE_SERVICE_KEY` | ACP & Odour | `iot_bad_odour`, ACP tables |

### Config files
- `src/config/supabaseAdmin.js` → Project 1 (service_role key)
- `src/config/supabase.js` → Project 1 (anon key — rarely used)
- `src/config/supabaseOld.js` → Project 2
- `src/config/supabaseAcp.js` → Project 3

### Railway MySQL (Legacy)
- Host: `103.227.176.27`, DB: `railway`, User: `smartcoachadmin`
- Used by some endpoints as fallback (mysql2 connection)
- Env vars: `MYSQLHOST`, `MYSQLUSER`, `MYSQL_ROOT_PASSWORD`, `MYSQLDATABASE`, `MYSQLPORT`

## Module → Division Mapping (RBAC)

Defined in `src/utils/rbac.js` constant `DIVISION_MODULE_MAP` and frontend `custom_drawer.dart`:

| Division | Allowed Modules |
|---|---|
| Danapur | `acp`, `hot_axle_section2`, `bc_pressure`, `sensor_config` |
| Nagpur | `brake_binding`, `hot_axle_section1`, `sensor_config` |
| Howrah | `brake_binding` |
| Kolkata | `brake_binding` |
| South Eastern | `brake_binding` |
| (unmapped) | ALL modules (default) |

## RBAC Rules (backend/src/utils/rbac.js)

### `getUserLocation(user)`
- Priority: `division_name > region_name > zone_name`
- Returns first non-null from JWT fields in that order
- All lookups are case-insensitive (`.toLowerCase()`)

### `getUserLocations(user)`
- Returns array of all location names (division, region, zone) that are non-null

### `isModuleAuthorized(user, moduleKey)`
- Gets `division_name` from JWT
- Looks up `DIVISION_MODULE_MAP[divisionName]`
- If division NOT in map → returns `true` (all modules allowed)
- If division IS in map → returns `true` only if moduleKey is in the array

### `getAuthorizedCoachNumbers(user)`
- Gets user location via `getUserLocation`
- Queries `coaches_railway` for matching `location` or `division` column
- Returns array of `coach_no` values
- Admin/superadmin returns `null` (no filter)

## Hot Axle Architecture

### Section 1 (HAMS)
- Backend name: `hot_axle_section1`
- LIVE data: Project 2 (`supabaseOld`) → `hams_data` table
- Only `master_id = 'HAMS-M1-001'` is live (hardcoded)
- Registration metadata: Project 1 → `coaches_hams` table
- Hardcoded values: coach_no=226965, train_no=1207069, brake_device_id=SCBB-NP-26-003, coach_type=LWSCZ - AC
- `getNewCompanyData` endpoint returns enriched hams_data rows
- `getHistory` with `isHams=true` returns grouped 15-min buckets

### Section 2 (New Company)
- Backend name: `hot_axle_section2`
- Data: Project 1 (`supabaseAdmin`) → `hot_axle_logs` table
- `getDashboardStatus` calls RPC `get_latest_per_device`
- Assigned to Danapur division

## Brake Binding Architecture

### Live data flow
- `event_publish` (Project 2) → new events
- `brake_fault_event` (Project 2) → fault events
- `bpc_pressure` table is in Project 1 but NOT in Project 2
  - Pneumatic model queries `supabaseOld` (Project 2) for bpc_pressure → fails (table missing)
  - Fix: must create `bpc_pressure` in Project 2 SQL Editor

### Pneumatic model (`src/models/pneumatic.model.js`)
- Queries `supabaseOld` for `bpc_pressure`
- Location filter: `division_name || region_name` (division first)
- Missing table returns `[]` instead of crashing

## Testing User
- `tester@example.com` bypasses mock data checks
- `kolkata@test.com`: division="Howrah" (id=17), region="Adra" (id=115), zone="Eastern Railway"

## Key Backend Files
- `src/utils/rbac.js` — RBAC helper functions
- `src/middleware/auth.middleware.js` — JWT auth, division_name fallback
- `src/middleware/rbac.middleware.js` — requireLocation middleware
- `src/controllers/hotAxleController.js` — Hot axle endpoints (both sections)
- `src/controllers/pneumatic.controller.js` — Brake binding controller
- `src/models/pneumatic.model.js` — Brake binding model
- `src/models/hotAxle.model.js` — Hot axle model

## Key Recent Fixes

### Hot Axle controller (hotAxleController.js)
- **Module auth**: All endpoints now check `isModuleAuthorized` before returning data
- **Section 1 HAMS**: Hardcoded to `master_id = 'HAMS-M1-001'` only (removed multi-master filter)
- **Section 2 bypass**: `getDashboardStatus` and `getHotAxleData` have `authorizedCoaches=null` bypass when user has `hot_axle_section2` (matches `getHistory` behavior)
- `getNewCompanyData`: Returns section 2 data for Danapur, section 1 HAMS for Nagpur, empty for others

### Pneumatic controller (pneumatic.controller.js) — Brake Binding
- **3-tier coach cascade**: `getCoachesByLocation` tries Project 2 → Project 1 → hardcoded deviceMapping
- **Consistent location**: All location lookups use `rbac.getUserLocation()` (division > region > zone)
- **Fallback fix**: `getBreakBindingData` fallback also checks Project 1's `coaches_railway`

### ACP controller (acpController.js)
- **Security fix**: `applyLocationFilter` now returns `[]` instead of unfiltered data when no match
- **Module guard**: `isModuleAuthorized('acp')` added to all GET endpoints (was missing on 3)

### Brake binding cache (frontend)
- **Singleton cache bug**: `BrakeBindingCache` is a singleton; User A's coach list was served to User B on login
- **Fix**: Always fetch fresh coaches from API; cache used only for instant display then invalidated

## Common Issues
1. New users may have `division_name` missing from JWT (registration doesn't pull it) — fresh login required
2. `bpc_pressure` table missing in Project 2 → sensor readings fail silently
3. Hot axle section 1 data only comes from HAMS-M1-001 — all other master_ids have no live data
4. `validateStatus: (status) => status < 500` in Dio means 4xx are treated as success
5. Division name in JWT must be populated — auth.middleware has fallback to query DB if missing
6. BrakeBindingCache singleton persists across login sessions — always clears on re-init now
7. Hot axle section 2 showing 0 values usually means `hot_axle_logs` is empty or RPC `get_latest_per_device` missing in Project 1

## Build
- Frontend: Flutter APK build (standard `flutter build apk` / `flutter build appbundle`)
- Backend: Push to Railway (auto-deploy from main branch)
