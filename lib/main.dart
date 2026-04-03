import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/reminder_provider.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Non-blocking initializations to avoid Black Screen on slower devices
    NotificationService().init();
    initializeService();
    
    runApp(const WaterReminderApp());
  } catch (e, stack) {
    debugPrint('Critical Startup Error: $e');
    debugPrint(stack.toString());
    // Fallback to ensuring the app at least tries to render
    runApp(const WaterReminderApp());
  }
}

class WaterReminderApp extends StatelessWidget {
  const WaterReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: MaterialApp(
        title: 'Water Reminder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF0074D9),
          scaffoldBackgroundColor: const Color(0xFF001F3F),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF0074D9),
            secondary: Color(0xFF7FDBFF),
            surface: Color(0xFF001F3F),
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
