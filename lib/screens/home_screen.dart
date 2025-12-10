import 'package:flutter/material.dart';
import '../services/step_service.dart';
import '../widgets/sensor_status_card.dart';
import '../widgets/progress_circle.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StepService _stepService = StepService();

  @override
  void initState() {
    super.initState();
    _stepService.init();
    
    // Listener khusus untuk memunculkan Dialog Selamat
    _stepService.addListener(() {
      if (_stepService.todaySteps >= _stepService.targetSteps && 
          !_stepService.hasShownCongratulation && 
          _stepService.todaySteps > 0) {
        _showCongratulationDialog();
        _stepService.markCongratulationShown();
      }
    });
  }

  @override
  void dispose() {
    _stepService.dispose();
    super.dispose();
  }

  void _showEditTargetDialog() {
    TextEditingController controller = TextEditingController(text: _stepService.targetSteps.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Atur Target Harian"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Target Langkah"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              int? newTarget = int.tryParse(controller.text);
              if (newTarget != null) {
                _stepService.setTarget(newTarget);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  void _showCongratulationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(children: [
          Icon(Icons.emoji_events, size: 60, color: Colors.orange),
          Text("Target Tercapai!"),
        ]),
        content: Text("Hebat! Kamu mencapai ${_stepService.targetSteps} langkah!"),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup"))],
      ),
    );
  }

  void _handleSync() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Syncing...")));
    bool success = await _stepService.forceSync();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? "Sukses!" : "Gagal"),
      backgroundColor: success ? Colors.teal : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder akan me-rebuild UI setiap kali notifyListeners() dipanggil di Service
    return ListenableBuilder(
      listenable: _stepService,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Jejak Sehat'),
            backgroundColor: _stepService.isUsingHardwareSensor ? Colors.teal : Colors.orange,
            actions: [
              IconButton(icon: const Icon(Icons.cloud_upload), onPressed: _handleSync)
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SensorStatusCard(
                    status: _stepService.sensorStatus,
                    isHardware: _stepService.isUsingHardwareSensor,
                  ),
                  const SizedBox(height: 30),
                  StepProgressCircle(
                    steps: _stepService.todaySteps,
                    target: _stepService.targetSteps,
                    percent: _stepService.percent,
                    isHardware: _stepService.isUsingHardwareSensor,
                    onEditTarget: _showEditTargetDialog,
                  ),
                  const SizedBox(height: 50),
                  OutlinedButton.icon(
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text("Lihat Riwayat"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}