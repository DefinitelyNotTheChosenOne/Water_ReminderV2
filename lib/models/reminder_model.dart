class WaterReminderModel {
  final int intervalMinutes;
  final int dailyGoalMl;
  final DateTime? lastDrinkTime;
  final List<String> todayLogs;
  final List<String> completedDates;
  final Map<String, List<String>> historyLogs;
  final String soundAsset;
  final DateTime? nextReminderTime;

  WaterReminderModel({
    required this.intervalMinutes,
    required this.dailyGoalMl,
    this.lastDrinkTime,
    required this.todayLogs,
    this.completedDates = const [],
    this.historyLogs = const {},
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
    Map<String, List<String>>? historyLogs,
    String? soundAsset,
    DateTime? nextReminderTime,
  }) {
    return WaterReminderModel(
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      lastDrinkTime: lastDrinkTime ?? this.lastDrinkTime,
      todayLogs: todayLogs ?? this.todayLogs,
      completedDates: completedDates ?? this.completedDates,
      historyLogs: historyLogs ?? this.historyLogs,
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
      'historyLogs': historyLogs,
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
      historyLogs: (json['historyLogs'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ??
          {},
      soundAsset: json['soundAsset'] ?? 'assets/sounds/drop.wav',
      nextReminderTime: json['nextReminderTime'] != null
          ? DateTime.parse(json['nextReminderTime'])
          : null,
    );
  }
}
