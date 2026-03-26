import 'dart:async';
import 'package:flutter/material.dart';

import '../models/home_model.dart';
import '../models/server.dart';
import '../services/api_service.dart';

class HomeController extends ChangeNotifier {
  final HomeModel _model = HomeModel();

  bool get isConnected =>
      _model.connectionState == VpnConnectionState.connected;
  bool get isConnecting =>
      _model.connectionState == VpnConnectionState.connecting;
  bool get isDisconnecting =>
      _model.connectionState == VpnConnectionState.disconnecting;

  List<Server> get servers => _model.servers;
  Server? get selectedServer => _model.selectedServer;
  String? get errorMessage => _model.lastError;

  bool isLoadingServers = false;

  int remainingSeconds = 1 * 60;
  Timer? _timer;

  String downloadSpeed = '0.0 Mbps';
  String uploadSpeed = '0.0 Mbps';

  Future<void> loadServers() async {
    isLoadingServers = true;
    _model.lastError = null;
    notifyListeners();

    try {
      await _model.fetchServers();
      if (_model.selectedServer == null && _model.servers.isNotEmpty) {
        _model.selectServer(_model.servers.first);
      }
    } on ApiException {
      // error is stored in _model.lastError
    }

    isLoadingServers = false;
    notifyListeners();
  }

  void selectServer(Server server) {
    _model.selectServer(server);
    notifyListeners();
  }

  void startTimer(VoidCallback onTick, VoidCallback onDisconnect) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        downloadSpeed = '${10 + (remainingSeconds % 50)} Mbps';
        uploadSpeed = '${5 + (remainingSeconds % 20)} Mbps';
        onTick();
        notifyListeners();
      } else {
        disconnect();
        onDisconnect();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    downloadSpeed = '0.0 Mbps';
    uploadSpeed = '0.0 Mbps';
    notifyListeners();
  }

  Future<void> connect(
    VoidCallback onSuccess,
    VoidCallback onTick,
    VoidCallback onDisconnect,
  ) async {
    if (selectedServer == null) {
      _model.lastError = 'Please select a server first';
      notifyListeners();
      return;
    }

    _model.lastError = null;
    _model.connectionState = VpnConnectionState.connecting;
    notifyListeners();

    try {
      await _model.connectToServer(selectedServer!.id);
      notifyListeners();

      startTimer(onTick, onDisconnect);
      onSuccess();
    } on ApiException {
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    if (selectedServer == null) return;

    _model.connectionState = VpnConnectionState.disconnecting;
    notifyListeners();

    stopTimer();

    try {
      await _model.disconnectFromServer(selectedServer!.id);
    } catch (_) {
      // still mark as disconnected even if API call fails
    }

    notifyListeners();
  }

  void addTime(int minutes) {
    remainingSeconds += minutes * 60;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _model.dispose();
    super.dispose();
  }
}
