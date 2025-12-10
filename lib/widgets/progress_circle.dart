import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StepProgressCircle extends StatelessWidget {
  final int steps;
  final int target;
  final double percent;
  final bool isHardware;
  final VoidCallback onEditTarget; // Callback saat tombol edit ditekan

  const StepProgressCircle({
    super.key,
    required this.steps,
    required this.target,
    required this.percent,
    required this.isHardware,
    required this.onEditTarget,
  });

  @override
  Widget build(BuildContext context) {
    final colorTheme = isHardware ? Colors.teal : Colors.orange;

    return CircularPercentIndicator(
      radius: 130.0,
      lineWidth: 15.0,
      animation: true,
      animateFromLastPercent: true,
      percent: percent,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_walk, size: 60, color: colorTheme),
          Text(
            "$steps",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 45.0),
          ),
          const Text("Langkah Hari Ini", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: InkWell(
          onTap: onEditTarget,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Target: $target",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: colorTheme,
      backgroundColor: Colors.grey.shade200,
    );
  }
}