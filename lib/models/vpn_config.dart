class VpnConfig {
  final String privateKey;
  final String clientIp;
  final String serverPublicKey;
  final String clientPublicKey;
  final String endpoint;

  VpnConfig({
    required this.privateKey,
    required this.clientIp,
    required this.serverPublicKey,
    required this.clientPublicKey,
    required this.endpoint,
  });

  factory VpnConfig.fromJson(Map<String, dynamic> json) {
    return VpnConfig(
      privateKey: json['private_key'] as String,
      clientIp: json['client_ip'] as String,
      serverPublicKey: json['server_public_key'] as String,
      clientPublicKey: (json['client_public_key'] as String?) ?? '',
      endpoint: json['endpoint'] as String,
    );
  }
}
