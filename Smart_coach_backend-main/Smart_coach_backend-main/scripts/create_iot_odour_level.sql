CREATE TABLE IF NOT EXISTS iot_odour_level (
  id BIGSERIAL PRIMARY KEY,
  sensor_id TEXT,
  train_id TEXT,
  coach_id TEXT,
  value NUMERIC,
  timestamp TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_iot_odour_train_coach ON iot_odour_level(train_id, coach_id);
CREATE INDEX IF NOT EXISTS idx_iot_odour_sensor ON iot_odour_level(sensor_id);

NOTIFY pgrst, 'reload schema';
