import 'dart:async';
import 'package:flutter/material.dart';

import '../models/app_config.dart';
import '../models/app_user.dart';
import '../models/home_model.dart';
import '../models/rewarded_ad_tier.dart';
import '../models/server.dart';
import '../services/api_client.dart';
import '../services/user_service.dart';

class HomeController extends ChangeNotifier {
  final HomeModel _model;
  final UserService _userService = UserService();
  final String deviceId;
  final AppConfigResponse? appConfig;
  final List<RewardedAdTier> adTiers;

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

  int remainingSeconds;
  Timer? _timer;
  int _ticksSinceSync = 0;

  String downloadSpeed = '0.0 Mbps';
  String uploadSpeed = '0.0 Mbps';

  HomeController({
    required this.deviceId,
    this.appConfig,
    AppUser? appUser,
  })  : _model = HomeModel(deviceId: deviceId, dns: appConfig?.dns ?? '1.1.1.3, 1.0.0.3'),
        adTiers = appConfig?.rewardedAdTiers ?? [],
        remainingSeconds = appUser?.remainingSeconds ??
            appConfig?.initialRemainingSeconds ??
            300 {
    // Request VPN permission early so the dialog appears before user taps Connect
    _model.ensureVpnPermission();
  }

  Future<void> loadServers({String? langCode}) async {
    isLoadingServers = true;
    _model.lastError = null;
    notifyListeners();

    final previousId = _model.selectedServer?.id;

    try {
      await _model.fetchServers(langCode: langCode);

      if (previousId != null) {
        final match = _model.servers
            .where((s) => s.id == previousId)
            .firstOrNull;
        _model.selectServer(match ?? _model.servers.firstOrNull);
      } else if (_model.servers.isNotEmpty) {
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
    _ticksSinceSync = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        _ticksSinceSync++;
        downloadSpeed = '${10 + (remainingSeconds % 50)} Mbps';
        uploadSpeed = '${5 + (remainingSeconds % 20)} Mbps';
        onTick();
        notifyListeners();

        // Sync remaining time to backend every 30 seconds
        if (_ticksSinceSync >= 30) {
          _ticksSinceSync = 0;
          _syncTimeToBackend();
        }
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

    // Persist remaining time to backend
    _syncTimeToBackend();

    notifyListeners();
  }

  Future<void> _syncTimeToBackend() async {
    try {
      await _userService.syncTime(deviceId, remainingSeconds);
    } catch (_) {
      // Silent fail — will sync next time
    }
  }

  /// Claim reward from backend after watching ads.
  Future<void> claimReward(RewardedAdTier tier) async {
    try {
      final updatedUser = await _userService.claimReward(deviceId, tier.id);
      remainingSeconds = updatedUser.remainingSeconds;
      notifyListeners();
    } on ApiException {
      // Fallback: add time locally if backend is unreachable
      remainingSeconds += tier.rewardMinutes * 60;
      notifyListeners();
    }
  }

  void addTime(int minutes) {
    remainingSeconds += minutes * 60;
    notifyListeners();
  }

  void updateRemainingSeconds(int seconds) {
    remainingSeconds = seconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _model.dispose();
    _userService.dispose();
    super.dispose();
  }
}
