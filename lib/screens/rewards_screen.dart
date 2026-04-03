import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import 'dart:ui';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReminderProvider>(context);
    final count = provider.data.availableRewardsCount;

    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: AppBar(
        title: const Text('Gift Shop 🎁'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF001F3F), Color(0xFF0074D9)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.photo_library_outlined, color: Color(0xFF7FDBFF), size: 100),
                          const SizedBox(height: 30),
                          const Text(
                            "Picture from Bebu ❤️",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "You have $count pictures available to redeem!",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: count > 0 ? () => _showRedeemDialog(context, provider) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              disabledBackgroundColor: Colors.white10,
                            ),
                            child: const Text(
                              'REDEEM 1 PICTURE',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                   "Complete your 100% daily goal to stack rewards!",
                   style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, ReminderProvider provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF001F3F),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                   Padding(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/images/rewards/bebu_picture_reward.png'),
                    ),
                   ),
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                     child: Text(
                        "Enjoy! 💝",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                     ),
                   ),
                   const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
               onPressed: () {
                  provider.redeemPicture();
                  Navigator.pop(context);
               },
               child: const Text("CLOSE & CLAIM"),
            ),
          ],
        ),
      ),
    );
  }
}
