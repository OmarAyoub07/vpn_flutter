class ConnectionStatus {
  final String status;
  final int activeConnections;

  ConnectionStatus({
    required this.status,
    required this.activeConnections,
  });

  factory ConnectionStatus.fromJson(Map<String, dynamic> json) {
    return ConnectionStatus(
      status: json['status'] as String,
      activeConnections: json['active_connections'] as int,
    );
  }
}
