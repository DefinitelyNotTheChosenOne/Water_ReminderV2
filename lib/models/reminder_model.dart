class WaterReminderModel {
  final int intervalMinutes;
  final int dailyGoalMl;
  final DateTime? lastDrinkTime;
  final List<String> todayLogs;
  final List<String> completedDates;
  final int availableRewardsCount;
  final String soundAsset;
  final DateTime? nextReminderTime;

  WaterReminderModel({
    required this.intervalMinutes,
    required this.dailyGoalMl,
    this.lastDrinkTime,
    required this.todayLogs,
    this.completedDates = const [],
    this.availableRewardsCount = 0,
    this.soundAsset = 'assets/sounds/drop.wav',
    this.nextReminderTime,
  });

  int get currentIntakeMl => todayLogs.length * 200;
  double get progress {
    if (dailyGoalMl <= 0) return 0.0;
    return ((todayLogs.length * 200) / dailyGoalMl).clamp(0.0, 1.0);
  }
  bool get isGoalMet => progress >= 1.0;

  WaterReminderModel copyWith({
    int? intervalMinutes,
    int? dailyGoalMl,
    DateTime? lastDrinkTime,
    List<String>? todayLogs,
    List<String>? completedDates,
    int? availableRewardsCount,
    String? soundAsset,
    DateTime? nextReminderTime,
  }) {
    return WaterReminderModel(
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      lastDrinkTime: lastDrinkTime ?? this.lastDrinkTime,
      todayLogs: todayLogs ?? this.todayLogs,
      completedDates: completedDates ?? this.completedDates,
      availableRewardsCount: availableRewardsCount ?? this.availableRewardsCount,
      soundAsset: soundAsset ?? this.soundAsset,
      nextReminderTime: nextReminderTime ?? this.nextReminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intervalMinutes': intervalMinutes,
      'dailyGoalMl': dailyGoalMl,
      'lastDrinkTime': lastDrinkTime?.toIso8601String(),
      'todayLogs': todayLogs,
      'completedDates': completedDates,
      'availableRewardsCount': availableRewardsCount,
      'soundAsset': soundAsset,
      'nextReminderTime': nextReminderTime?.toIso8601String(),
    };
  }

  factory WaterReminderModel.fromJson(Map<String, dynamic> json) {
    return WaterReminderModel(
      intervalMinutes: json['intervalMinutes'] ?? 30,
      dailyGoalMl: json['dailyGoalMl'] ?? 2000,
      lastDrinkTime: json['lastDrinkTime'] != null
          ? DateTime.parse(json['lastDrinkTime'])
          : null,
      todayLogs: List<String>.from(json['todayLogs'] ?? []),
      completedDates: List<String>.from(json['completedDates'] ?? []),
      availableRewardsCount: json['availableRewardsCount'] ?? 0,
      soundAsset: json['soundAsset'] ?? 'assets/sounds/drop.wav',
      nextReminderTime: json['nextReminderTime'] != null
          ? DateTime.parse(json['nextReminderTime'])
          : null,
    );
  }
}
