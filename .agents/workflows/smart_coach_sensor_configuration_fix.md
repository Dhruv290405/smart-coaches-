---
description: Sensor Configuration and Dashboard Fixes Implementation Plan
---

## Overview
This workflow implements the fixes for issues 48‑115 covering sensor configuration, coach dashboard, ACP dashboard, FSDS bypass, hot axle, BC pressure, water level, bad odour, global modules, and reports.

### Phase‑wise Steps
1. **Core Utilities**
   - Add `SearchableDropdown<T>` widget (`frontend/lib/core/widgets/searchable_dropdown.dart`).
   - Extend `device_id_mapper.dart` with `deviceNameMap` and `getDeviceName`.
   - Add status colors in `app_colors.dart` (`onlineColor = Colors.green`, `offlineColor = Colors.red`).
   - Ensure `ExportUtils` (`frontend/lib/core/utils/export_utils.dart`) is imported and an **Export CSV** button added to each configuration table.

2. **Backend Corrections**
   - Update `sensor.controller.js` to return correct status flags and all sensor fields.
   - Fix `coach.controller.js` joins for device IDs and ensure newly created coaches are returned immediately.
   - Adjust `acp.controller.js`, `fsds.controller.js`, `water_level.controller.js`, and other controllers to use the updated `datetime.js` for IST timestamps.
   - Remove hard‑coded mappings (e.g., Raspberry Pi) from `pneumatic.controller.js`.

3. **Frontend UI Fixes**
   - Replace plain dropdowns with `SearchableDropdown` in sensor configuration page, coach dashboard, and other modules.
   - Update sensor table to display device names via `getDeviceName`.
   - Refactor status display to use `onlineColor`/`offlineColor`.
   - Remove dummy data arrays and fetch real data from APIs across all dashboards.
   - Implement proper chart data sources for ACP, Hot Axle, BC Pressure, FSDS Bypass, etc.
   - Redesign Bad Odour UI to show toilet‑wise data.
   - Add PDF report generators under `frontend/lib/reports/` for each module.

4. **Integration & Testing**
   - Write end‑to‑end test `test/e2e/configuration_flow_test.dart` covering train → coach → master module → sensor mapping.
   - Add unit tests for new mapper functions and export flow.
   - Run full test suite (`flutter test --coverage` and `npm test`).

5. **Cleanup & Finalization**
   - Search and remove all placeholder dummy data across the repo.
   - Verify timestamp consistency globally.
   - Prioritize SMS OTP integration (Twilio) in `auth.controller.js`.
   - Commit all changes with clear messages.

**Execution**: Follow the phases sequentially. After each phase, run the relevant unit/integration tests and verify UI behavior.
