-- =====================================================================
-- Performance indexes (read-only speed-up; no data or behaviour change)
-- =====================================================================
-- HOW TO RUN (Supabase dashboard -> SQL Editor):
--   * Run each block in the project it belongs to (Project 1 / 2 / 3).
--   * CREATE INDEX CONCURRENTLY does not block live device inserts, but it
--     cannot run inside a multi-statement batch: select ONE statement at a
--     time and press Run (or Ctrl+Enter on the highlighted line).
--   * "IF NOT EXISTS" makes every statement safe to re-run.
--   * Large tables (event_publish, hams_data, bad_odour_data) can take a few
--     minutes per index; wait for "Success" before running the next one.
--   * If a CONCURRENTLY build is interrupted it leaves an INVALID index:
--     DROP INDEX CONCURRENTLY <name>; then run the CREATE again.
-- =====================================================================


-- ---------------------------------------------------------------------
-- PROJECT 3  (qcycuwfohxmdatrtawlw)  -- Bad Odour + ACP
-- ---------------------------------------------------------------------
-- Bad odour coach detail chart (latest readings per device) and dashboard.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_bad_odour_data_device_ts
  ON public.bad_odour_data ("device_ID", "timestamp" DESC);

-- Dashboard "latest reading" + weekly report date range.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_bad_odour_data_ts
  ON public.bad_odour_data ("timestamp" DESC);

-- ACP logs / summary / filters (msg_type = METRICS ordered by created_at).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_railway_acp_data_msg_created
  ON public.railway_acp_data (msg_type, created_at DESC);

-- ACP coach history.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_railway_acp_data_asset_created
  ON public.railway_acp_data (asset_name, created_at DESC);


-- ---------------------------------------------------------------------
-- PROJECT 1  (zfzpjlxbhvsofhbcoyxr)  -- users, notifications, hot axle sec 2
-- ---------------------------------------------------------------------
-- Notification list in the app (per user, newest first).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_notifications_user_created
  ON public.user_notifications (user_id, created_at DESC);

-- Alert duplicate checks (type + title within last 2 h / 30 min).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_notifications_type_title_created
  ON public.user_notifications (type, title, created_at DESC);

-- Push recipients lookup.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_fcm_tokens_user
  ON public.user_fcm_tokens (user_id);

-- Login by email.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_master_email
  ON public.user_master (email);

-- Hot axle section 2 (per device, newest first).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_hot_axle_logs_device_ts
  ON public.hot_axle_logs (device_id, "timestamp" DESC);

-- BC pressure dashboard (per device, newest first).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pressure_logs_device_ts
  ON public.pressure_logs (device_id, "timestamp" DESC);


-- ---------------------------------------------------------------------
-- PROJECT 2  (ajikchaxkmxcyuecqmce)  -- Brake binding + HAMS (live)
-- ---------------------------------------------------------------------
-- Brake binding live status per device (newest first).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_event_publish_device_ts
  ON public.event_publish (device_id, "timestamp" DESC);

-- Brake fault list per device (newest first).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_brake_fault_event_device_ts
  ON public.brake_fault_event (device_id, "timestamp" DESC);

-- Brake fault list (all devices, newest first).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_brake_fault_event_ts
  ON public.brake_fault_event ("timestamp" DESC);

-- Hot axle HAMS (section 1) per master / device.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_hams_data_master_created
  ON public.hams_data (master_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_hams_data_device_created
  ON public.hams_data (device_id, created_at DESC);
