import 'package:flutter/material.dart';

class SensorStatusCard extends StatelessWidget {
  final String status;
  final bool isHardware;

  const SensorStatusCard({
    super.key,
    required this.status,
    required this.isHardware,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isHardware ? Icons.memory : Icons.vibration,
            color: isHardware ? Colors.teal : Colors.orange[800],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                color: isHardware ? Colors.teal : Colors.orange[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}