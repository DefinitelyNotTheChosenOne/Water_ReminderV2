import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedHours = 0;
  int _selectedMinutes = 30;
  int _selectedGoal = 2000;
  String _selectedSound = 'assets/sounds/drop.wav';

  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ReminderProvider>(context, listen: false);
    final total = provider.data.intervalMinutes;
    _selectedHours = total ~/ 60;
    _selectedMinutes = total % 60;
    if (_selectedHours == 0 && _selectedMinutes == 0) _selectedMinutes = 1;
    _selectedGoal = provider.data.dailyGoalMl;
    _selectedSound = provider.data.soundAsset;
    _goalController.text = _selectedGoal.toString();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  int get _totalMinutes => (_selectedHours * 60) + _selectedMinutes;

  String get _intervalLabel {
    final h = _selectedHours;
    final m = _selectedMinutes;
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReminderProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text(
          'Preferences',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('REMINDER INTERVAL'),
                const SizedBox(height: 16),
                _buildTimerPicker(),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _totalMinutes == 0
                        ? 'Minimum 1 minute required'
                        : 'Alert every $_intervalLabel',
                    style: TextStyle(
                      color: _totalMinutes == 0 ? Colors.redAccent : const Color(0xFF00D2FF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildSectionHeader('NOTIFICATION SOUND'),
                const SizedBox(height: 16),
                _buildSoundSelector(provider),
                const SizedBox(height: 40),
                _buildSectionHeader('DAILY HYDRATION GOAL'),
                const SizedBox(height: 16),
                _buildGoalInput(),
                if (_selectedGoal < 1800 || _selectedGoal > 2500)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Recommended: 1,800 - 2,500 ml',
                          style: TextStyle(
                            color: Colors.orangeAccent.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 60),
                _buildSaveButton(provider),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildTimerPicker() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              _buildPickerColumn('Hours', _selectedHours, 6, (val) => setState(() => _selectedHours = val)),
              Text(
                ':',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildPickerColumn('Minutes', _selectedMinutes, 60, (val) => setState(() => _selectedMinutes = val)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerColumn(String label, int value, int count, ValueChanged<int> onChanged) {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(initialItem: value),
              itemExtent: 45,
              onSelectedItemChanged: onChanged,
              selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(background: Colors.transparent),
              children: List.generate(
                count,
                (i) => Center(
                  child: Text(
                    i.toString().padLeft(2, '0'),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSelector(ReminderProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: AppSounds.all.asMap().entries.map((entry) {
          final sound = entry.value;
          final isSelected = _selectedSound == sound.asset;
          return Column(
            children: [
              ListTile(
                onTap: () => setState(() => _selectedSound = sound.asset),
                leading: Text(sound.icon, style: const TextStyle(fontSize: 24)),
                title: Text(
                  sound.label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF00D2FF) : Colors.white,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.play_circle_outline, color: Colors.white38),
                  onPressed: () => provider.previewSound(sound.asset),
                ),
              ),
              if (entry.key != AppSounds.all.length - 1)
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _goalController,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          icon: Icon(Icons.water_drop_outlined, color: Color(0xFF00D2FF)),
          border: InputBorder.none,
          suffixText: 'ml',
          suffixStyle: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold),
        ),
        onChanged: (val) => setState(() => _selectedGoal = int.tryParse(val) ?? 0),
      ),
    );
  }

  Widget _buildSaveButton(ReminderProvider provider) {
    final isValid = _totalMinutes > 0 && _selectedGoal >= 1800 && _selectedGoal <= 2500;
    return GestureDetector(
      onTap: isValid
          ? () {
              provider.setPreferences(_totalMinutes, _selectedGoal, _selectedSound);
              Navigator.pop(context);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 60,
        decoration: BoxDecoration(
          gradient: isValid
              ? const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)])
              : const LinearGradient(colors: [Color(0xFF333333), Color(0xFF444444)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isValid
              ? [BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))]
              : [],
        ),
        child: const Center(
          child: Text(
            'SAVE CHANGES',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
        ),
      ),
    );
  }
}
