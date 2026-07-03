DROP TABLE IF EXISTS odour_logs CASCADE;

CREATE TABLE odour_logs (
  id BIGSERIAL PRIMARY KEY,
  master_sensor_id TEXT,
  device_id TEXT,
  train_number TEXT,
  coach_number TEXT,
  coach_type TEXT,
  toilet_position TEXT DEFAULT 'N/A',
  odour_reading INTEGER DEFAULT 0,
  device_status TEXT DEFAULT 'Unknown',
  voc NUMERIC DEFAULT 0,
  h2s NUMERIC DEFAULT 0,
  nh3 NUMERIC DEFAULT 0,
  smoke NUMERIC DEFAULT 0,
  temperature NUMERIC,
  humidity NUMERIC,
  latitude NUMERIC,
  longitude NUMERIC,
  timestamp TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_odour_device_id ON odour_logs(device_id);
CREATE INDEX IF NOT EXISTS idx_odour_timestamp ON odour_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_odour_device_ts ON odour_logs(device_id, id DESC);

NOTIFY pgrst, 'reload schema';
