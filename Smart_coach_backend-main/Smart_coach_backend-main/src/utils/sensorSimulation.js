// sensorSimulator.js
const sensors = [
  { id: 1, sensorId: "SD-1000", waterLevel: 0, increasing: true },
  { id: 2, sensorId: "SD-1001", waterLevel: 50, increasing: true },
  { id: 3, sensorId: "SD-1002", waterLevel: 100, increasing: false },
];

// Helper to simulate water level for a single sensor
function updateSensor(sensor) {
  const change = Math.floor(Math.random() * 10) + 1; // random change 1–10

  if (sensor.increasing) {
    sensor.waterLevel += change;
    if (sensor.waterLevel >= 100) {
      sensor.waterLevel = 100;
      sensor.increasing = false;
    }
  } else {
    sensor.waterLevel -= change;
    if (sensor.waterLevel <= 0) {
      sensor.waterLevel = 0;
      sensor.increasing = true;
    }
  }

  return {
    id: sensor.id,
    sensorId: sensor.sensorId,
    waterLevel: sensor.waterLevel,
    timestamp: new Date().toISOString(),
  };
}

// Periodically simulate sensor data
function startSensorSimulation(callback) {
  setInterval(() => {
    const results = sensors.map((sensor) => updateSensor(sensor));
    callback(results);
  }, 15 * 60 * 1000); // every 15 minutes
}

module.exports = { startSensorSimulation };
