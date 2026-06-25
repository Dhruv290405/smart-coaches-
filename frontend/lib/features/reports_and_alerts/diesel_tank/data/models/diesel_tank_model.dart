class DieselTankModel {
  final String engineId;
  final String sensorId;
  final String locoNumber;
  final String trainName;
  final int percentage;
  final String status;
  final double height;
  final double width;
  final double length;
  final int capacity;
  final int consumptionRate;
  final double estimatedRunTime;
  final int rangeLeft;
  final String refilledBy;
  final DateTime lastUpdated;

  DieselTankModel({
    required this.engineId,
    required this.sensorId,
    required this.locoNumber,
    required this.trainName,
    required this.percentage,
    required this.status,
    required this.height,
    required this.width,
    required this.length,
    required this.capacity,
    required this.consumptionRate,
    required this.estimatedRunTime,
    required this.rangeLeft,
    required this.refilledBy,
    required this.lastUpdated,
  });

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory DieselTankModel.fromJson(Map<String, dynamic> json) {
    return DieselTankModel(
      engineId: json['loco_number'] as String? ?? '',
      sensorId: json['sensor_id'] as String? ?? '',
      locoNumber: json['loco_number'] as String? ?? '',
      trainName: json['train_name'] as String? ?? '',
      percentage: _parseInt(json['percentage']) ?? 0,
      status: json['status'] as String? ?? 'Good',
      height: _parseDouble(json['height']) ?? 180,
      width: _parseDouble(json['width']) ?? 120,
      length: _parseDouble(json['length']) ?? 220,
      capacity: _parseInt(json['capacity']) ?? 5000,
      consumptionRate: _parseInt(json['consumption_rate']) ?? 400,
      estimatedRunTime: _parseDouble(json['estimated_run_time']) ?? 0,
      rangeLeft: _parseInt(json['range_left']) ?? 0,
      refilledBy: json['refilled_by'] as String? ?? 'N/A',
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loco_number': locoNumber,
      'sensor_id': sensorId,
      'train_name': trainName,
      'percentage': percentage,
      'status': status,
      'height': height,
      'width': width,
      'length': length,
      'capacity': capacity,
      'consumption_rate': consumptionRate,
      'estimated_run_time': estimatedRunTime,
      'range_left': rangeLeft,
      'refilled_by': refilledBy,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  String getFormattedLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Updated just now';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Updated ${difference.inHours} hr ago';
    } else {
      return 'Updated ${difference.inDays} day ago';
    }
  }

  String getFormattedDate() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = lastUpdated.hour > 12
        ? lastUpdated.hour - 12
        : lastUpdated.hour == 0
            ? 12
            : lastUpdated.hour;
    final amPm = lastUpdated.hour >= 12 ? 'AM' : 'PM';
    final minute = lastUpdated.minute.toString().padLeft(2, '0');
    return '${lastUpdated.day.toString().padLeft(2, '0')} ${months[lastUpdated.month - 1]}, ${lastUpdated.year} | $hour:$minute $amPm';
  }
}
