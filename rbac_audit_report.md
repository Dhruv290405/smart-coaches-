# 🔍 Smart Coach RBAC & Data Visibility — Full Audit Report
**Date**: 2026-07-24 | **Scope**: Nagpur & Danapur Divisions

---

## 1. User Configuration (Database)

| Email | Role | Zone | Division | Region |
|---|---|---|---|---|
| `nagpur@test.com` | 3 (User) | South East Central Railway (zone_id=3) | **Nagpur** (div_id=14) | *null* |
| `danapur.ops@test.com` | 3 (User) | East Central Railway (zone_id=15) | **Danapur** (div_id=67) | Danapur (region_id=138) |

> [!NOTE]
> [getUserLocation()](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/rbac.js#31-38) returns the **first non-null** of: `region_name` → `division_name` → `zone_name`.
> - Nagpur → `"Nagpur"` (from division)
> - Danapur → `"Danapur"` (from region)

---

## 2. Expected Module Visibility

| Module | Nagpur | Danapur |
|---|---|---|
| Brake Binding | ✅ Should show | ❌ No data |
| Hot Axle Section 1 (HAMS) | ✅ Should show | ❌ No data |
| Hot Axle Section 2 (logs) | ❌ No data | ✅ Should show |
| ACP | ❌ No data | ✅ Should show |
| BC Pressure | ❌ No data | ✅ Should show |
| Water Tank (WLI) | ❌ No data | ❌ No data |
| Bad Odour | ❌ No data | ❌ No data |
| Diesel Level | ❌ No data | ❌ No data |
| FSDS | ❌ No data | ❌ No data |

---

## 3. RBAC Core: `coaches_railway` Table

This table is the **sole data source** for [getAuthorizedCoachNumbers()](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/rbac.js#98-112) — the primary RBAC filter used by most controllers.

| Location | Coaches | Device IDs |
|---|---|---|
| **Nagpur** | `B2`, `C3` | `Raspberry4_5`, `Raspberry4_6` |
| Howrah | `D3`, `S5`, `S3` | ... |
| Jaipur | `B1`, `S5` | ... |
| kurduwadi | `B1` | ... |
| **Danapur** | ⚠️ **NONE** | **NONE** |

> [!CAUTION]
> **`coaches_railway` has ZERO entries for Danapur.** This means [getAuthorizedCoachNumbers()](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/rbac.js#98-112) returns `[]` (empty array) for Danapur users, causing cascading failures across all modules.

---

## 4. Data Source Mapping

| Data Table | ID Field | Location Field | Danapur Data? | Nagpur Data? |
|---|---|---|---|---|
| `coaches_railway` | `coach_no` (B2, C3) | [Location](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/rbac.js#31-38) | ❌ None | ✅ 2 entries |
| `coaches_hams` | `actual_id` | `location` | ❌ None | ✅ 3 entries (Axel_1A, HAMS-M1-001) |
| `hot_axle_logs` | `coach_number` (HA-DN-02) | *none* | ✅ Has logs | ✅ Has logs |
| `railway_acp_data` | `asset_name` | `loc_name` (="VASP ACP Train X") | ❌ No "Danapur" match | ❌ No "Nagpur" match |
| `pressure_logs` | `coach_number` (BC2512xxx) | *none* | ✅ Has logs | ✅ Has logs |
| `sensor_config` | `tech_coach_no` | `location` (route names) | ❌ No "Danapur" match | ❌ No "Nagpur" match |
| `wli_logs` | `coach_name` | *none* | 0 rows | 0 rows |
| `iot_bad_odour` | `coach_number` | *none* | 0 rows total | 0 rows total |
| `fsds_logs` | `asset_name` | `loc_name` | 1 row | 1 row |

---

## 5. Per-Controller RBAC Audit

### 5.1 Brake Binding (`coaches_railway` → `coaches_railway`)

| Aspect | Status | Detail |
|---|---|---|
| RBAC source | `coaches_railway.Location` | Direct table match |
| Nagpur | ✅ Works | 2 coaches (B2, C3) with `Location='Nagpur'` |
| Danapur | ✅ Correctly empty | No coaches_railway entries for Danapur |
| **Verdict** | ✅ **CORRECT** | |

### 5.2 Hot Axle Section 1 — HAMS (`coaches_hams` → `hams_data`)

| Aspect | Status | Detail |
|---|---|---|
| Data source | Old Supabase `hams_data` table | Linked via `coaches_hams.actual_id` → `hams_data.master_id` |
| Nagpur HAMS entries | ✅ 3 devices | `Axel_1A`, `HAMS-M1-001` (×2) with `location='Nagpur'` |
| Controller filter | ⚠️ **NO division check** | [hotAxleController.js:136-164](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#L136-L164) — [getHistory](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#122-470) HAMS path fetches by `master_id` only, no user location validation |
| [getNewCompanyData](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#507-658) | ⚠️ Checks `region_name` | [Line 509](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#L509): `req.user.region_name === 'danapur'` — Nagpur user has `region_name=null` so falls through to HAMS path ✅ |
| Danapur accessing HAMS | ⚠️ **BUG** | [getHistory](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#122-470) with `coachType=HAMS` would serve HAMS data to Danapur users |
| **Verdict** | ⚠️ **PARTIALLY BROKEN** | Works for Nagpur in [getNewCompanyData](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#507-658), but [getHistory](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#122-470) HAMS has no guard |

### 5.3 Hot Axle Section 2 — Logs (`hot_axle_logs`)

| Aspect | Status | Detail |
|---|---|---|
| RBAC source | [getAuthorizedCoachNumbers()](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/rbac.js#98-112) via `coaches_railway` | |
| Nagpur | Coaches `[B2, C3]` don't match `hot_axle_logs.coach_number` (HA-DN-02 etc.) | Returns empty ✅ |
| Danapur | `[]` empty array | |
| Model bug | ⚠️ **CRITICAL** | [hotAxle.model.js:26-28](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/models/hotAxle.model.js#L26-L28): `if (authorizedCoaches && authorizedCoaches.length > 0)` — **empty array bypasses filter, returns ALL data** |
| Same bug in | [getData()](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/models/hotAxle.model.js#16-41), [getLatestStatusForAllCoaches()](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/models/odour.model.js#23-55), [getHistoryData()](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/models/hotAxle.model.js#42-77) | All 3 methods |
| **Verdict** | ❌ **BROKEN** | Danapur sees ALL hot_axle_logs (including non-Danapur). Empty `[]` should block, not pass. |

### 5.4 ACP (`railway_acp_data` — separate Supabase)

| Aspect | Status | Detail |
|---|---|---|
| [getAcpLogs](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#7-35) | ⚠️ Filter exists but **mismatched** | [acpController.js:14-22](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#L14-L22): Filters by `train_location` containing user location. But `loc_name = "VASP ACP Train X"` never contains "Danapur" or "Nagpur" → **blocks ALL division users** |
| [getAcpSummary](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#152-167) | ❌ **NO FILTER** | [acpController.js:153-166](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#L153-L166): Returns ALL data to everyone |
| [getFilterOptions](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#471-480) | ❌ **NO FILTER** | [acpController.js:101-125](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#L101-L125) |
| [getFilteredData](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#127-151) | ❌ **NO FILTER** | [acpController.js:128-150](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#L128-L150) |
| [getCoachHistory](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#168-197) | ❌ **NO FILTER** | [acpController.js:169-196](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#L169-L196) |
| **Verdict** | ❌ **BROKEN** | Nagpur sees ACP summary (shouldn't). Danapur can't see ACP logs (should). |

### 5.5 BC Pressure (`pressure_logs`)

| Aspect | Status | Detail |
|---|---|---|
| RBAC source | [getAuthorizedCoachNumbers()](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/rbac.js#98-112) | |
| Empty array handling | ✅ Correct | [pressure.model.js:55-57](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/models/pressure.model.js#L55-L57): `if (authorizedCoaches !== null && length === 0) return []` |
| Danapur | ❌ Returns `[]` | Because `coaches_railway` has no Danapur entries, `authorizedCoaches=[]`, model returns empty |
| Nagpur | ✅ Returns `[]` | Coach nos `[B2,C3]` don't match `pressure_logs.coach_number` (BC2512xxx) |
| **Verdict** | ❌ **BROKEN for Danapur** | Pressure data exists but Danapur can't see it due to empty `coaches_railway` |

### 5.6 Water Tank / WLI (`wli_logs`)

| Aspect | Status | Detail |
|---|---|---|
| Empty array handling | ✅ Correct | [wli.model.js:25-27](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/models/wli.model.js#L25-L27) |
| Data | 0 rows in table | No data for any division |
| **Verdict** | ✅ **CORRECT** (no data exists anyway) | |

### 5.7 Bad Odour (`iot_bad_odour` — ACP Supabase)

| Aspect | Status | Detail |
|---|---|---|
| Empty array handling | ✅ Correct | [odour.model.js:29-31](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/models/odour.model.js#L29-L31) |
| Data | 1 test row total | Minimal data |
| Nagpur/Danapur | Both get `[]` | Coach `C001` not in either's authorized list |
| **Verdict** | ✅ **CORRECT** (no relevant data) | |

### 5.8 FSDS (`fsds_logs`)

| Aspect | Status | Detail |
|---|---|---|
| RBAC | ❌ **NONE** | [fsdsController.js:53-76](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/fsdsController.js#L53-L76): [getData()](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/models/hotAxle.model.js#16-41) returns all data, no auth filtering |
| Data | 1 row | Minimal |
| **Verdict** | ❌ **BROKEN** | All users see all FSDS data (should be division-filtered) |

### 5.9 Diesel (`sensor_config` type=6 + `sensor_data`)

| Aspect | Status | Detail |
|---|---|---|
| Empty array handling | ✅ Correct | [diesel.model.js:15-17](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/models/diesel.model.js#L15-L17) |
| Data | 0 diesel sensors (sensor_type_id=6) | No diesel configs exist |
| **Verdict** | ✅ **CORRECT** (no data exists) | |

---

## 6. Bug Summary

| # | Severity | Bug | Impact | File |
|---|---|---|---|---|
| 1 | 🔴 Critical | `coaches_railway` has **zero Danapur entries** | All coach-based filtering blocks Danapur from ALL modules | Database |
| 2 | 🔴 Critical | Hot Axle model: empty `[]` **bypasses** filter | Danapur sees ALL hot_axle_logs data | [hotAxle.model.js](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/models/hotAxle.model.js) |
| 3 | 🔴 Critical | ACP [getAcpSummary](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#152-167) has **NO RBAC** | Nagpur sees all ACP summaries | [acpController.js](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js) |
| 4 | 🟠 High | ACP [getAcpLogs](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#7-35) location mismatch | `"VASP ACP Train X"` never matches "Danapur" → Danapur can't see ACP | [acpController.js:14-22](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#L14-L22) |
| 5 | 🟠 High | ACP [getFilterOptions](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#471-480), [getFilteredData](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#127-151), [getCoachHistory](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js#168-197) — no RBAC | Any user accesses any ACP data | [acpController.js](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/acpController.js) |
| 6 | 🟠 High | FSDS controller — no RBAC | All users see all FSDS | [fsdsController.js](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/fsdsController.js) |
| 7 | 🟡 Medium | Hot Axle [getHistory](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#122-470) HAMS path — no division guard | Danapur can fetch Nagpur HAMS data | [hotAxleController.js:136-164](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#L136-L164) |
| 8 | 🟡 Medium | [getNewCompanyData](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#507-658) checks `region_name` not `division_name` | Fragile — works only because Nagpur has `region_name=null` | [hotAxleController.js:509](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/controllers/hotAxleController.js#L509) |

---

## 7. Root Cause

> [!WARNING]
> **The `coaches_railway` table was designed for Brake Binding (SCBB) devices only.** It contains device-specific coach letter codes (B2, C3, S5) with Location tags. The codebase incorrectly uses this as the **universal RBAC filter** for ALL modules (ACP, Pressure, Hot Axle, WLI, Odour, Diesel).
>
> This fails because:
> - ACP coach numbers are 6-digit tech IDs (`255391`, `216821/C`) — don't match `B2`/`C3`
> - Pressure coach numbers are device IDs (`BC2512039`) — don't match
> - Hot Axle coach numbers are device IDs (`HA-DN-02`) — don't match
> - `coaches_railway` has no Danapur entries at all

---

## 8. Recommended Fix: Division-Module Authorization

Instead of relying on `coaches_railway`, implement a **division-to-module whitelist** in [rbac.js](file:///e:/SMART%20-%20COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/rbac.js):

```javascript
const DIVISION_MODULES = {
  'Danapur': ['acp', 'hot_axle_section2', 'bc_pressure', 'sensor_config'],
  'Nagpur':  ['brake_binding', 'hot_axle_section1', 'sensor_config'],
};
```

Each controller checks `isModuleAuthorized(user, 'module_name')`:
- **Authorized** → return all module data (no coach-level filter needed since the module itself is division-scoped)
- **Not authorized** → return empty `{ data: [] }`
- **Admin** → bypass, return everything

This is the **minimal, reliable fix** that:
1. Eliminates the `coaches_railway` dependency for non-brake-binding modules
2. Fixes empty-array leaks
3. Properly scopes ACP, Pressure, Hot Axle data per division
4. Is easy to extend when new divisions/modules are added
