class AppUser {
  final String deviceId;
  final String referralCode;
  final int remainingSeconds;
  final String createdAt;
  final String lastSeenAt;
  final String? referralStatus;

  AppUser({
    required this.deviceId,
    required this.referralCode,
    required this.remainingSeconds,
    required this.createdAt,
    required this.lastSeenAt,
    this.referralStatus,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      deviceId: json['device_id'],
      referralCode: json['referral_code'] ?? '',
      remainingSeconds: json['remaining_seconds'],
      createdAt: json['created_at'] ?? '',
      lastSeenAt: json['last_seen_at'] ?? '',
      referralStatus: json['referral_status'],
    );
  }
}
