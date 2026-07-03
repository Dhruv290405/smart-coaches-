CREATE OR REPLACE FUNCTION get_latest_per_device()
RETURNS SETOF hot_axle_logs AS
$func$
  SELECT DISTINCT ON (device_id) *
  FROM hot_axle_logs
  ORDER BY device_id, id DESC;
$func$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_latest_per_coach()
RETURNS SETOF pressure_logs AS
$func$
  SELECT DISTINCT ON (coach_number) *
  FROM pressure_logs
  WHERE coach_number IS NOT NULL AND coach_number != ''
  ORDER BY coach_number, id DESC;
$func$ LANGUAGE sql;

CREATE INDEX IF NOT EXISTS idx_hot_axle_device_id ON hot_axle_logs(device_id);
CREATE INDEX IF NOT EXISTS idx_hot_axle_timestamp ON hot_axle_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_hot_axle_device_ts ON hot_axle_logs(device_id, id DESC);
CREATE INDEX IF NOT EXISTS idx_pressure_coach_number ON pressure_logs(coach_number);
CREATE INDEX IF NOT EXISTS idx_pressure_timestamp ON pressure_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_pressure_coach_ts ON pressure_logs(coach_number, id DESC);

NOTIFY pgrst, 'reload schema';
