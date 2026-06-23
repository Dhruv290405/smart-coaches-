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
