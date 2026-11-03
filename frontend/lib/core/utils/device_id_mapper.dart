import 'package:smart_coach_new/core/config/remote_app_config.dart';

class DeviceIdMapper {
  static const Map<String, String> _map = {
    'Raspberry4_1': 'SCBB-JP-26-001',
    'Raspberry4_2': 'SCBB-HWH-26-001',
    'Raspberry4_3': 'SCBB-HWH-26-002',
    'Raspberry4_4': 'SCBB-JP-26-002',
    'Raspberry4_5': 'SCBB-NP-26-001',
  };

  static String resolve(String? deviceId) {
    if (deviceId == null) return 'N/A';
    final remote = RemoteAppConfig.current.deviceMappings[deviceId];
    if (remote != null && remote.isNotEmpty) return remote;
    
    // Check if the deviceId is in our explicit map
    if (_map.containsKey(deviceId)) {
      return _map[deviceId]!;
    }

    // Hide any raw Raspberry Pi mentions if they leak from backend
    if (deviceId.toLowerCase().contains('raspberry')) {
      return 'Smart Hub';
    }

    return deviceId;
  }
}
