class ConnectionStatus {
  final String status;
  final int activeConnections;
  final int? connectionId;

  ConnectionStatus({
    required this.status,
    required this.activeConnections,
    this.connectionId,
  });

  factory ConnectionStatus.fromJson(Map<String, dynamic> json) {
    return ConnectionStatus(
      status: json['status'] as String,
      activeConnections: json['active_connections'] as int,
      connectionId: json['connection_id'] as int?,
    );
  }
}
