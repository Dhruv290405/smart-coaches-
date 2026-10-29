-- All regions with their division and zone names
SELECT 
  r.region_id,
  r.name AS region_name,
  d.division_id,
  d.name AS division_name,
  z.zone_id,
  z.name AS zone_name
FROM region_master r
JOIN division_master d ON d.division_id = r.division_id
JOIN zone_master z ON z.zone_id = d.zone_id
WHERE r.is_active = 1
ORDER BY z.name, d.name, r.name;

-- Or if you want it grouped by zone (easier to read):
SELECT 
  z.name AS zone_name,
  d.name AS division_name,
  r.region_id,
  r.name AS region_name
FROM zone_master z
JOIN division_master d ON d.zone_id = z.zone_id
LEFT JOIN region_master r ON r.division_id = d.division_id AND r.is_active = 1
WHERE z.is_active = 1 AND d.is_active = 1
ORDER BY z.name, d.name, r.name;

-- Find divisions that have NO regions:
SELECT d.division_id, d.name AS division_name, z.name AS zone_name
FROM division_master d
JOIN zone_master z ON z.zone_id = d.zone_id
WHERE d.is_active = 1
  AND d.division_id NOT IN (
    SELECT DISTINCT division_id FROM region_master WHERE is_active = 1
  )
ORDER BY z.name, d.name;
