enum RewardType { kiss, hug, picture }

class Achievement {
  final String id;
  final String title;
  final String description;
  final double milestone; // 0.0 to 1.0 (0% to 100%)
  final RewardType rewardType;
  final String imagePath;
  final bool isUnlocked;
  final bool isClaimed;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.milestone,
    required this.rewardType,
    required this.imagePath,
    this.isUnlocked = false,
    this.isClaimed = false,
  });

  Achievement copyWith({
    bool? isUnlocked,
    bool? isClaimed,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      milestone: milestone,
      rewardType: rewardType,
      imagePath: imagePath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUnlocked': isUnlocked,
      'isClaimed': isClaimed,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json, Achievement template) {
    return template.copyWith(
      isUnlocked: json['isUnlocked'] ?? false,
      isClaimed: json['isClaimed'] ?? false,
    );
  }
}
