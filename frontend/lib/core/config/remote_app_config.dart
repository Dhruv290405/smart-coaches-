import 'dart:convert';

class RemoteAppConfig {
  static const Map<String, List<String>> _defaultDivisionModules = {
    'Danapur': ['acp', 'hot_axle_section2', 'bc_pressure', 'sensor_config'],
    'Nagpur': ['brake_binding', 'hot_axle_section1', 'sensor_config', 'odour'],
    'Howrah': ['brake_binding'],
    'Kolkata': ['brake_binding'],
    'South Eastern': ['brake_binding'],
    'Jaipur': ['brake_binding'],
  };

  static RemoteAppConfig current = RemoteAppConfig._(
    divisionModules: _defaultDivisionModules,
    rolePermissions: const {},
    deviceMappings: const {},
  );

  final Map<String, List<String>> divisionModules;
  final Map<int, Set<String>> rolePermissions;
  final Map<String, String> deviceMappings;

  RemoteAppConfig._({
    required this.divisionModules,
    required this.rolePermissions,
    required this.deviceMappings,
  });

  static RemoteAppConfig fromJson(Map<String, dynamic> json) {
    final divisions = <String, List<String>>{};
    final rawDivisions = json['divisionModules'];
    if (rawDivisions is Map) {
      for (final entry in rawDivisions.entries) {
        if (entry.key is String && entry.value is List) {
          divisions[entry.key as String] =
              (entry.value as List).whereType<String>().toList();
        }
      }
    }

    final permissions = <int, Set<String>>{};
    final rawPermissions = json['rolePermissions'];
    if (rawPermissions is Map) {
      for (final entry in rawPermissions.entries) {
        final roleId = int.tryParse(entry.key.toString());
        if (roleId != null && entry.value is List) {
          permissions[roleId] =
              (entry.value as List).whereType<String>().toSet();
        }
      }
    }

    final mappings = <String, String>{};
    final rawMappings = json['deviceMappings'];
    if (rawMappings is Map) {
      for (final entry in rawMappings.entries) {
        if (entry.key is String && entry.value is String) {
          mappings[entry.key as String] = entry.value as String;
        }
      }
    }

    return RemoteAppConfig._(
      divisionModules:
          divisions.isEmpty ? _defaultDivisionModules : divisions,
      rolePermissions: permissions,
      deviceMappings: mappings,
    );
  }

  static String encode(RemoteAppConfig config) => jsonEncode({
        'divisionModules': config.divisionModules,
        'rolePermissions': config.rolePermissions.map(
          (key, value) => MapEntry(key.toString(), value.toList()),
        ),
        'deviceMappings': config.deviceMappings,
      });
}
