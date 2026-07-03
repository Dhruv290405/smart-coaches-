CREATE OR REPLACE FUNCTION get_latest_odour_per_device()
RETURNS SETOF odour_logs AS
$func$
  SELECT DISTINCT ON (device_id) *
  FROM odour_logs
  WHERE device_id IS NOT NULL
  ORDER BY device_id, id DESC;
$func$ LANGUAGE sql;

NOTIFY pgrst, 'reload schema';
