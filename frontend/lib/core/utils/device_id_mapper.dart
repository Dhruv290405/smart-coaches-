class DeviceIdMapper {
  static const Map<String, String> _map = {
    'Raspberry4_1': 'SCBB-JP-26-001',
    'Raspberry4_2': 'SCBB-HWH-26-001',
    'Raspberry4_3': 'SCBB-HWH-26-002',
    'Raspberry4_4': 'SCBB-JP-26-002',
    'Raspberry4_5': 'SCBB-NP-26-001',
    'SCBB-HWH-26-003': 'SCBB-HWH-26-003',
  };

  static String resolve(String? deviceId) {
    if (deviceId == null) return 'N/A';
    
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
