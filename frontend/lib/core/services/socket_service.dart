import 'dart:async';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:smart_coach_new/core/network/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._();
  factory SocketService() => _instance;
  SocketService._();

  io.Socket? _socket;
  bool _connected = false;

  final _acpController = StreamController<Map<String, dynamic>>.broadcast();
  final _fsdsController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get acpStream => _acpController.stream;
  Stream<Map<String, dynamic>> get fsdsStream => _fsdsController.stream;

  bool get isConnected => _connected;

  void connect() {
    if (_socket != null) return;

    final uri = Uri.parse(ApiConstants.devUrl);
    final serverUrl = '${uri.scheme}://${uri.host}';

    log('[SocketIO] Connecting to $serverUrl');

    _socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 3000,
    });

    _socket!.onConnect((_) {
      _connected = true;
      log('[SocketIO] Connected');
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      log('[SocketIO] Disconnected');
    });

    _socket!.on('acp:update', (data) {
      if (data is Map) {
        _acpController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('fsds:update', (data) {
      if (data is Map) {
        _fsdsController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.onConnectError((err) {
      log('[SocketIO] Connect error: $err');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _connected = false;
  }

  void dispose() {
    disconnect();
    _acpController.close();
    _fsdsController.close();
  }
}