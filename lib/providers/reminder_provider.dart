import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/reminder_model.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import 'package:intl/intl.dart';

class ReminderProvider with ChangeNotifier, WidgetsBindingObserver {
  final StorageService _storage = StorageService();
  final NotificationService _notification = NotificationService();
  final AudioService _audio = AudioService();

  WaterReminderModel _data = WaterReminderModel(
    intervalMinutes: 30,
    dailyGoalMl: 2000,
    todayLogs: [],
    completedDates: [],
    soundAsset: 'assets/sounds/drop.wav',
  );

  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  WaterReminderModel get data => _data;
  Duration get remainingTime => _remainingTime;
  bool _isActive = false;
  bool get isActive => _isActive;
  
  bool _isWaitingForDrink = false;
  bool get isWaitingForDrink => _isWaitingForDrink;

  ReminderProvider() {
    _init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Background engine is now always enabled, so we don't stop reminders on pause/detach.
  }

  Future<void> _init() async {
    try {
      final savedData = await _storage.getReminderData();
      if (savedData != null) {
        _data = savedData;
        _reconcileLogs();
        
        // RESTORE TIMER IF ACTIVE
        if (_data.nextReminderTime != null) {
          final now = DateTime.now();
          if (_data.nextReminderTime!.isAfter(now)) {
             _remainingTime = _data.nextReminderTime!.difference(now);
             _isActive = true;
             _startTimer();
          } else {
             // Time passed while app was closed — just flag waiting, no sound/notification spam
             _isWaitingForDrink = true;
             _isActive = false;
             // Clear the stale time silently
             _data = _data.copyWith(nextReminderTime: null);
             _storage.saveReminderData(_data);
          }
        }
      }
      await _notification.init();
      notifyListeners();
    } catch (e) {
      debugPrint('Error during ReminderProvider._init: $e');
    }
  }

  void toggleReminders() {
    if (_isWaitingForDrink) {
      _isWaitingForDrink = false;
    }
    _isActive = !_isActive;
    if (_isActive) {
      startReminders();
    } else {
      stopReminders();
    }
    notifyListeners();
  }

  void startReminders() async {
    _isActive = true;
    _isWaitingForDrink = false;
    _remainingTime = Duration(minutes: _data.intervalMinutes);
    
    final nextTime = DateTime.now().add(_remainingTime);
    _data = _data.copyWith(nextReminderTime: nextTime);
    _storage.saveReminderData(_data);
    
    _startTimer();
    
    // Always schedule system-level alarms & Background Engine
    await _notification.requestExactAlarmsPermission();
    
    _notification.scheduleNotification(_data.intervalMinutes);
    
    final bgService = FlutterBackgroundService();
    if (!(await bgService.isRunning())) {
      await bgService.startService();
    }
    bgService.invoke('setNextTime', {'time': nextTime.toIso8601String()});
    
    notifyListeners();
  }

  void stopReminders() {
    _isActive = false;
    _countdownTimer?.cancel();
    _notification.stopNotifications();
    
    _data = _data.copyWith(nextReminderTime: null);
    _storage.saveReminderData(_data);
    
    _stopBackgroundService();
    
    notifyListeners();
  }

  /// Stops the background service by sending both stop events to the isolate.
  /// The service's internal listener will call stopSelf() on receipt.
  void _stopBackgroundService() {
    final bgService = FlutterBackgroundService();
    bgService.invoke('stop');        // cancels the periodic timer inside the isolate
    bgService.invoke('stopService'); // triggers service.stopSelf() inside the isolate
  }

  void recordIntake(bool drank) {
    if (drank) {
      final now = DateTime.now();
      final nowIso = now.toIso8601String();
      _data = _data.copyWith(
        lastDrinkTime: now,
        todayLogs: [..._data.todayLogs, nowIso],
      );
      
      _checkGoalCompletion();
      _storage.saveReminderData(_data);
      
      if (_isActive || _isWaitingForDrink) {
         startReminders();
      }
    }
    notifyListeners();
  }

  void _checkGoalCompletion() {
    if (_data.progress >= 1.0) {
      final logicalDateStr = _getLogicalDateString(DateTime.now());
      if (!_data.completedDates.contains(logicalDateStr)) {
        _data = _data.copyWith(
          completedDates: [..._data.completedDates, logicalDateStr],
        );
        _audio.playSound(_data.soundAsset);
      }
    }
  }

  /// Processes logs from previous logical days and archives them.
  void _reconcileLogs() {
    final now = DateTime.now();
    final currentLogicalDateStr = _getLogicalDateString(now);
    
    // Group logs by their logical date
    Map<String, List<String>> logsByDay = {};
    List<String> currentDayLogs = [];
    
    for (var logIso in _data.todayLogs) {
      try {
        final logTime = DateTime.parse(logIso);
        final logDayStr = _getLogicalDateString(logTime);
        
        if (logDayStr == currentLogicalDateStr) {
          currentDayLogs.add(logIso);
        } else {
          logsByDay.putIfAbsent(logDayStr, () => []).add(logIso);
        }
      } catch (_) {}
    }
    
    // Check old days for completion
    bool changed = false;
    List<String> newCompletedDates = List.from(_data.completedDates);
    
    logsByDay.forEach((dayStr, logs) {
      // Calculate progress for that specific old day
      final totalMl = logs.length * 250; // assuming 250ml per log as per UI
      if (totalMl >= _data.dailyGoalMl && !newCompletedDates.contains(dayStr)) {
        newCompletedDates.add(dayStr);
        changed = true;
      }
    });
    
    if (changed || _data.todayLogs.length != currentDayLogs.length) {
      _data = _data.copyWith(
        todayLogs: currentDayLogs,
        completedDates: newCompletedDates,
      );
      _storage.saveReminderData(_data);
    }
  }

  DateTime? _lastArchiveCheck;

  void _startTimer() {
    _countdownTimer?.cancel();
    _lastArchiveCheck = DateTime.now();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      
      // PERIODIC 6 AM CHECK
      if (_lastArchiveCheck != null && 
          _getLogicalDateString(now) != _getLogicalDateString(_lastArchiveCheck!)) {
        _reconcileLogs();
        notifyListeners();
      }
      _lastArchiveCheck = now;

      if (_remainingTime.inSeconds > 0) {
        _remainingTime -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        _audio.playSound(_data.soundAsset);
        _notification.showInstantNotification(
           'Drink Water!', 
           'You need to drink water now! 💧'
        );
        _isWaitingForDrink = true;
        _isActive = false;
        _countdownTimer?.cancel();
        notifyListeners();
      }
    });
  }

  void setPreferences(int intervalMinutes, int goalMl, String soundAsset) {
    _data = _data.copyWith(
      intervalMinutes: intervalMinutes,
      dailyGoalMl: goalMl,
      soundAsset: soundAsset,
    );
    _storage.saveReminderData(_data);
    
    if (_isActive) {
      // Re-start to sync everything with the new settings
      startReminders();
    }
    notifyListeners();
  }

  void previewSound(String assetPath) {
    _audio.playSound(assetPath);
  }

  DateTime _getLogicalDate(DateTime dt) {
    // Shifting back by 6 hours means:
    // 0:00 - 5:59 AM on Date X becomes 6:00 - 11:59 PM on Date X-1
    return dt.subtract(const Duration(hours: 6));
  }

  String _getLogicalDateString(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(_getLogicalDate(dt));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audio.dispose();
    super.dispose();
  }
}
