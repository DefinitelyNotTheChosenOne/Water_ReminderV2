import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';

class StorageService {
  static const String _key = 'water_reminder_data';

  Future<void> saveReminderData(WaterReminderModel data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  Future<WaterReminderModel?> getReminderData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_key);
    if (dataString == null) return null;
    return WaterReminderModel.fromJson(jsonDecode(dataString));
  }
}
