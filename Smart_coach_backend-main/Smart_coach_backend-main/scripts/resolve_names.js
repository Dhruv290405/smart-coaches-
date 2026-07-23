const fetch = require('node-fetch');

async function resolveIds() {
  const res = await fetch('https://api.vaspsystemic.com/inspect-db');
  const json = await res.json();
  
  const div67 = json.divisions.find(d => d.division_id === 67);
  const div14 = json.divisions.find(d => d.division_id === 14);
  const reg138 = json.regions.find(r => r.region_id === 138);
  
  console.log('Division 67 matches:', div67);
  console.log('Division 14 matches:', div14);
  console.log('Region 138 matches:', reg138);
}

resolveIds();
