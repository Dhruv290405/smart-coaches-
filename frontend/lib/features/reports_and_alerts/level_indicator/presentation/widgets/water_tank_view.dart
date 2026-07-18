import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_coach_new/core/utils/logger.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/data/datasources/sensor_api_service.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/data/models/sensor_data.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/presentation/widgets/water_tank_card.dart';

final Logger _log = Logger('WaterTank');

class WaterTank {
  final int id;
  final String name;
  final int percentage;

  WaterTank({
    required this.id,
    required this.name,
    required this.percentage,
  });

  WaterTank copyWith({int? percentage}) {
    return WaterTank(
      id: id,
      name: name,
      percentage: percentage ?? this.percentage,
    );
  }
}

class WaterTankView extends StatefulWidget {
  final List<BasicSensorItem> sensors;
  final SensorApiService apiService;

  const WaterTankView({
    super.key,
    required this.sensors,
    required this.apiService,
  });

  @override
  State<WaterTankView> createState() => _WaterTankViewState();
}

class _WaterTankViewState extends State<WaterTankView> {
  Map<String, SensorData> sensorDataMap = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    debugPrint("INIT STATE CALLED ✅");
    _fetchAllSensors();
    _startAutoRefresh();
  }

  @override
  void didUpdateWidget(covariant WaterTankView oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("Wdget: ${widget.sensors}");
    // Check if the sensors list has changed
    if (oldWidget.sensors != widget.sensors) {
      debugPrint("Sensors list updated ✅ -> Fetching new data");
      _fetchAllSensors();
    }
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _fetchAllSensors();
    });
  }

  Future<void> _fetchAllSensors() async {
    for (var sensor in widget.sensors) {
      try {
        final data = await widget.apiService.fetchSensorData(sensor.sensor_id);
        print("Sensor Data: ${data.waterLevel}");
        print("Sensor Data: ${data.sensorId}");
        print("Sensor Data: ${data.timestamp}");
        setState(() {
          sensorDataMap[sensor.sensor_id] = data;
        });
      } catch (e) {
        _log.error('Error fetching data for sensor ${sensor.sensor_id}', e);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Water Tank',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 5,
          runSpacing: 8,
          children: widget.sensors.map((sensor) {
            final sensorData = sensorDataMap[sensor.sensor_id];
            return WaterTankCard(
              tank: WaterTank(
                id: sensor.sensor_config_id,
                name: sensor.sensor_id,
                percentage: (sensorData?.waterLevel ?? 0).toInt(),

              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
