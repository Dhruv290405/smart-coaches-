CREATE TABLE IF NOT EXISTS odour_management_live (
  id BIGSERIAL PRIMARY KEY,
  device_id TEXT,
  sensor_id TEXT,
  train_number TEXT,
  coach_number TEXT,
  coach_type TEXT,
  toilet_position TEXT,
  temperature NUMERIC,
  humidity NUMERIC,
  voc_index INTEGER,
  methane_ppm NUMERIC,
  h2s_ppm NUMERIC,
  nh3_ppm NUMERIC,
  sraw_voc TEXT,
  h2s_raw TEXT,
  nh3_raw TEXT,
  long_lock_count INTEGER,
  timestamp TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE odour_management_live ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "Allow all reads" ON odour_management_live FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE POLICY "Allow all inserts" ON odour_management_live FOR INSERT WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE POLICY "Allow all updates" ON odour_management_live FOR UPDATE USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
