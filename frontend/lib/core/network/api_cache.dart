import 'dart:collection';

class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;
  _CacheEntry(this.data, this.expiresAt);
}

class ApiCache {
  final HashMap<String, _CacheEntry> _store = HashMap();
  final Duration defaultTtl;

  ApiCache({this.defaultTtl = const Duration(seconds: 30)});

  void set(String key, dynamic data, {Duration? ttl}) {
    _store[key] = _CacheEntry(data, DateTime.now().add(ttl ?? defaultTtl));
  }

  dynamic get(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key);
      return null;
    }
    return entry.data;
  }

  void invalidate(String key) {
    _store.remove(key);
  }

  void invalidateAll() {
    _store.clear();
  }

  String makeKey(String endpoint, [Map<String, dynamic>? params]) {
    if (params == null || params.isEmpty) return endpoint;
    final sorted = params.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return '$endpoint?${sorted.map((e) => '${e.key}=${e.value}').join('&')}';
  }
}
