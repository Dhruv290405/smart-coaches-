-- Fix auto-increment sequences
SELECT setval(pg_get_serial_sequence('zone_master', 'id'), (SELECT COALESCE(MAX(id),1) FROM zone_master));
SELECT setval(pg_get_serial_sequence('division_master', 'id'), (SELECT COALESCE(MAX(id),1) FROM division_master));
SELECT setval(pg_get_serial_sequence('region_master', 'id'), (SELECT COALESCE(MAX(id),1) FROM region_master));
SELECT setval(pg_get_serial_sequence('role_master', 'id'), (SELECT COALESCE(MAX(id),1) FROM role_master));
SELECT setval(pg_get_serial_sequence('coach_make', 'id'), (SELECT COALESCE(MAX(id),1) FROM coach_make));
SELECT setval(pg_get_serial_sequence('coach_type', 'id'), (SELECT COALESCE(MAX(id),1) FROM coach_type));
SELECT setval(pg_get_serial_sequence('sensor_make', 'id'), (SELECT COALESCE(MAX(id),1) FROM sensor_make));
SELECT setval(pg_get_serial_sequence('train_master', 'train_id'), (SELECT COALESCE(MAX(train_id),1) FROM train_master));
SELECT setval(pg_get_serial_sequence('device_master', 'id'), (SELECT COALESCE(MAX(id),1) FROM device_master));
SELECT setval(pg_get_serial_sequence('sensor_master', 'id'), (SELECT COALESCE(MAX(id),1) FROM sensor_master));
SELECT setval(pg_get_serial_sequence('stations', 'id'), (SELECT COALESCE(MAX(id),1) FROM stations));
SELECT setval(pg_get_serial_sequence('coach_master', 'coach_id'), (SELECT COALESCE(MAX(coach_id),1) FROM coach_master));
SELECT setval(pg_get_serial_sequence('user_master', 'user_id'), (SELECT COALESCE(MAX(user_id),1) FROM user_master));
SELECT setval(pg_get_serial_sequence('hot_axle_logs', 'id'), (SELECT COALESCE(MAX(id),1) FROM hot_axle_logs));
SELECT setval(pg_get_serial_sequence('pressure_logs', 'id'), (SELECT COALESCE(MAX(id),1) FROM pressure_logs));
SELECT setval(pg_get_serial_sequence('acp_critical_events', 'id'), (SELECT COALESCE(MAX(id),1) FROM acp_critical_events));
SELECT setval(pg_get_serial_sequence('device_live_summary', 'id'), (SELECT COALESCE(MAX(id),1) FROM device_live_summary));
SELECT setval(pg_get_serial_sequence('odour_logs', 'id'), (SELECT COALESCE(MAX(id),1) FROM odour_logs));
SELECT setval(pg_get_serial_sequence('sensor_data', 'id'), (SELECT COALESCE(MAX(id),1) FROM sensor_data));

-- Fix sensor_config: drop FK, re-insert, re-add FK
ALTER TABLE sensor_config DROP CONSTRAINT IF EXISTS fk_sc_device;
