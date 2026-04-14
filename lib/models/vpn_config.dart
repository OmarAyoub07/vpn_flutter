import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class VpnConfig {
  final String privateKey;
  final String clientIp;
  final String serverPublicKey;
  final String endpoint;

  /// The client public key derived from the private key.
  /// Computed lazily on first access.
  String? _clientPublicKey;

  VpnConfig({
    required this.privateKey,
    required this.clientIp,
    required this.serverPublicKey,
    required this.endpoint,
  });

  /// Derives the WireGuard public key from the private key using X25519.
  Future<String> getClientPublicKey() async {
    if (_clientPublicKey != null) return _clientPublicKey!;

    final privateBytes = base64Decode(privateKey);
    final keyPair = SimpleKeyPairData(
      privateBytes,
      publicKey: SimplePublicKey(Uint8List(32), type: KeyPairType.x25519),
      type: KeyPairType.x25519,
    );

    final algorithm = X25519();
    final extracted = await algorithm.newKeyPairFromSeed(privateBytes);
    final publicKey = await extracted.extractPublicKey();
    _clientPublicKey = base64Encode(publicKey.bytes);
    return _clientPublicKey!;
  }

  factory VpnConfig.fromJson(Map<String, dynamic> json) {
    return VpnConfig(
      privateKey: json['private_key'] as String,
      clientIp: json['client_ip'] as String,
      serverPublicKey: json['server_public_key'] as String,
      endpoint: json['endpoint'] as String,
    );
  }
}
