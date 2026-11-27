-- Run this in Supabase SQL Editor for Project 3 (ACP): qcycuwfohxmdatrtawlw
-- Creates a PostgreSQL function for server-side aggregation of bad_odour_data.
-- This avoids transferring 500K+ rows to Node.js — aggregation runs in the DB.

CREATE OR REPLACE FUNCTION aggregate_odour_history(
  p_device_id TEXT,
  p_start_date TIMESTAMPTZ,
  p_end_date TIMESTAMPTZ,
  p_bucket_minutes INT DEFAULT 15
)
RETURNS TABLE (
  bucket_start TIMESTAMPTZ,
  avg_voc NUMERIC,
  avg_nh3 NUMERIC,
  avg_h2s NUMERIC,
  avg_methane NUMERIC,
  avg_temperature NUMERIC,
  avg_humidity NUMERIC,
  max_voc NUMERIC,
  max_nh3 NUMERIC,
  max_h2s NUMERIC,
  readings_count BIGINT
)
LANGUAGE sql STABLE
AS $$
  SELECT
    date_bin(
      (p_bucket_minutes || ' minutes')::INTERVAL,
      timestamp,
      p_start_date
    ) AS bucket_start,
    ROUND(AVG(voc_index)::NUMERIC, 2) AS avg_voc,
    ROUND(AVG(nh3_ppm)::NUMERIC, 2) AS avg_nh3,
    ROUND(AVG(h2s_ppm)::NUMERIC, 2) AS avg_h2s,
    ROUND(AVG(methane_ppm)::NUMERIC, 2) AS avg_methane,
    ROUND(AVG(temperature)::NUMERIC, 2) AS avg_temperature,
    ROUND(AVG(humidity)::NUMERIC, 2) AS avg_humidity,
    MAX(voc_index) AS max_voc,
    MAX(nh3_ppm) AS max_nh3,
    MAX(h2s_ppm) AS max_h2s,
    COUNT(*) AS readings_count
  FROM bad_odour_data
  WHERE "device_ID" = p_device_id
    AND timestamp >= p_start_date
    AND timestamp < p_end_date
  GROUP BY bucket_start
  ORDER BY bucket_start ASC;
$$;
