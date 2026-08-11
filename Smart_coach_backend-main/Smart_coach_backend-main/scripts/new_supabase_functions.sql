DROP FUNCTION IF EXISTS get_latest_per_device();
DROP FUNCTION IF EXISTS get_latest_per_coach();
DROP FUNCTION IF EXISTS get_latest_odour_per_device();
DROP FUNCTION IF EXISTS get_latest_wli_per_device();

CREATE OR REPLACE FUNCTION get_latest_per_device()
RETURNS SETOF hot_axle_logs
AS $$
  SELECT DISTINCT ON (h.device_id) h.*
  FROM hot_axle_logs h
  ORDER BY h.device_id, h.id DESC;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_latest_per_coach()
RETURNS SETOF pressure_logs
AS $$
  SELECT DISTINCT ON (p.coach_number) p.*
  FROM pressure_logs p
  ORDER BY p.coach_number, p.id DESC;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_latest_odour_per_device()
RETURNS SETOF odour_logs
AS $$
  SELECT DISTINCT ON (o.device_id) o.*
  FROM odour_logs o
  ORDER BY o.device_id, o.id DESC;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_latest_wli_per_device()
RETURNS SETOF wli_logs
AS $$
  SELECT DISTINCT ON (w.device_id, w.asset_id) w.*
  FROM wli_logs w
  ORDER BY w.device_id, w.asset_id, w.id DESC;
$$ LANGUAGE sql;
