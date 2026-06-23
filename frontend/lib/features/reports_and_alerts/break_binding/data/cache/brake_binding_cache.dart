import '../models/coach_by_location_response.dart';
import '../models/pneumatic_status_model.dart';

class BrakeBindingCache {
  BrakeBindingCache._();
  static final BrakeBindingCache instance = BrakeBindingCache._();

  static const Duration _coachesTtl = Duration(minutes: 5);
  static const Duration _statusTtl = Duration(seconds: 5);

  // Coaches cache
  List<CoachByLocationItem>? _coaches;
  DateTime? _coachesFetchedAt;

  bool get hasValidCoaches {
    if (_coaches == null || _coachesFetchedAt == null) return false;
    return DateTime.now().difference(_coachesFetchedAt!) < _coachesTtl;
  }

  List<CoachByLocationItem>? get coaches => hasValidCoaches ? _coaches : null;

  void setCoaches(List<CoachByLocationItem> coaches) {
    _coaches = coaches;
    _coachesFetchedAt = DateTime.now();
  }

  // Pneumatic status cache per deviceId
  final Map<String, PneumaticStatusResponse> _statusMap = {};
  final Map<String, DateTime> _statusFetchedAt = {};

  bool hasValidStatus(String deviceId) {
    final fetchedAt = _statusFetchedAt[deviceId];
    if (fetchedAt == null || !_statusMap.containsKey(deviceId)) return false;
    return DateTime.now().difference(fetchedAt) < _statusTtl;
  }

  PneumaticStatusResponse? getStatus(String deviceId) =>
      hasValidStatus(deviceId) ? _statusMap[deviceId] : null;

  void setStatus(String deviceId, PneumaticStatusResponse status) {
    _statusMap[deviceId] = status;
    _statusFetchedAt[deviceId] = DateTime.now();
  }

  void invalidateCoaches() {
    _coaches = null;
    _coachesFetchedAt = null;
  }

  void invalidateStatus(String deviceId) {
    _statusMap.remove(deviceId);
    _statusFetchedAt.remove(deviceId);
  }
}
