class ConnectionHistory {
  final int id;
  final String serverName;
  final String serverCountry;
  final String serverCountryFlag;
  final String? serverFlagImageUrl;
  final String connectedAt;
  final String? disconnectedAt;
  final int? durationSeconds;

  ConnectionHistory({
    required this.id,
    required this.serverName,
    required this.serverCountry,
    required this.serverCountryFlag,
    this.serverFlagImageUrl,
    required this.connectedAt,
    this.disconnectedAt,
    this.durationSeconds,
  });

  factory ConnectionHistory.fromJson(Map<String, dynamic> json) {
    return ConnectionHistory(
      id: json['id'],
      serverName: json['server_name'],
      serverCountry: json['server_country'],
      serverCountryFlag: json['server_country_flag'],
      serverFlagImageUrl: json['server_flag_image_url'],
      connectedAt: json['connected_at'],
      disconnectedAt: json['disconnected_at'],
      durationSeconds: json['duration_seconds'],
    );
  }

  String get formattedDuration {
    if (durationSeconds == null) return '--:--:--';
    final h = durationSeconds! ~/ 3600;
    final m = (durationSeconds! % 3600) ~/ 60;
    final s = durationSeconds! % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(connectedAt).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final connDate = DateTime(dt.year, dt.month, dt.day);

      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

      if (connDate == today) return 'Today, $time';
      if (connDate == yesterday) return 'Yesterday, $time';
      return '${dt.day}/${dt.month}/${dt.year}, $time';
    } catch (_) {
      return connectedAt;
    }
  }
}
