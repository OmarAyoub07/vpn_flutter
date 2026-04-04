class RewardedAdTier {
  final int id;
  final int adsToWatch;
  final int rewardMinutes;

  RewardedAdTier({
    required this.id,
    required this.adsToWatch,
    required this.rewardMinutes,
  });

  factory RewardedAdTier.fromJson(Map<String, dynamic> json) {
    return RewardedAdTier(
      id: json['id'],
      adsToWatch: json['ads_to_watch'],
      rewardMinutes: json['reward_minutes'],
    );
  }
}
