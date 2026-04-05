import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'water_reminder_bg_channel',
      initialNotificationTitle: 'WATER REMINDER',
      initialNotificationContent: 'INITIALIZING ENGINE...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // LOAD SETTINGS
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  
  DateTime? nextTime;

  service.on('setNextTime').listen((event) {
    if (event != null && event['time'] != null) {
      nextTime = DateTime.parse(event['time']);
    }
  });

  service.on('stop').listen((event) {
    nextTime = null;
  });

  Timer? timer;
  int tickCount = 0;
  
  service.on('stopService').listen((event) {
    timer?.cancel();
    service.stopSelf();
  });

  timer = Timer.periodic(const Duration(seconds: 1), (t) async {
    tickCount++;

    // We still call reload every 10 seconds to keep the isolate's 
    // internal SharedPreferences instance somewhat in sync with disk,
    // though the engine toggle is removed.
    if (tickCount % 10 == 0) {
      final p = await SharedPreferences.getInstance();
      await p.reload();
    }

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        if (nextTime != null) {
          final now = DateTime.now();
          final remaining = nextTime!.difference(now);
          if (remaining.inSeconds > 0) {
            String minutes = remaining.inMinutes.toString().padLeft(2, '0');
            String seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
            service.setForegroundNotificationInfo(
              title: "NEXT DRINK IN $minutes:$seconds",
              content: "Stay hydrated! 💧",
            );
          } else {
            service.setForegroundNotificationInfo(
              title: "DRINK WATER NOW! 💧",
              content: "Your reminder time has reached 0:00.",
            );
            nextTime = null;
          }
        } else {
          service.setForegroundNotificationInfo(
            title: "WATER REMINDER ACTIVE",
            content: "Ready when you are! 💧",
          );
        }
      }
    }
    service.invoke('update');
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}
