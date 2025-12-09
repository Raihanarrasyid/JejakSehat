import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'database_helper.dart';

void main() {
  runApp(const MaterialApp(home: JejakSehatApp()));
}

class JejakSehatApp extends StatefulWidget {
  const JejakSehatApp({super.key});

  @override
  State<JejakSehatApp> createState() => _JejakSehatAppState();
}

class _JejakSehatAppState extends State<JejakSehatApp> {
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  
  int _todaySteps = 0;
  int _targetSteps = 10000;
  double _percent = 0.0;
  
  String _sensorStatus = 'Menyiapkan Sensor...';
  bool _isUsingHardwareSensor = true;

  double _previousMagnitude = 0;
  final double _threshold = 12.0;
  int _manualSteps = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void initPlatformState() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _initHardwarePedometer();
    } else {
      setState(() {
        _sensorStatus = 'Izin sensor ditolak user';
      });
    }
  }

  void _initHardwarePedometer() {
    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream!.listen(onStepCount).onError((error) {
        _useAccelerometerFallback(); 
      });
    } catch (e) {
      _useAccelerometerFallback();
    }
  }

  void _useAccelerometerFallback() {
    setState(() {
      _isUsingHardwareSensor = false;
      _sensorStatus = 'Hardware Step Counter tidak ditemukan.\nMenggunakan Accelerometer.';
    });

    _accelSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      _detectStepFromAccel(event);
    });
  }

  void _detectStepFromAccel(UserAccelerometerEvent event) {
    double magnitude = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));

    if (magnitude > _threshold && _previousMagnitude <= _threshold) {
      setState(() {
        _manualSteps++;
        _todaySteps = _manualSteps;
        _updateProgress();
      });
    }
    _previousMagnitude = magnitude;
  }

  void onStepCount(StepCount event) {
    setState(() {
      _isUsingHardwareSensor = true;
      _sensorStatus = 'Menggunakan Sensor Bawaan HP';
      _todaySteps = event.steps; 
      _updateProgress();
    });
  }

  void _updateProgress() {
    _percent = (_todaySteps / _targetSteps);
    if (_percent > 1.0) _percent = 1.0;
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jejak Sehat'),
        backgroundColor: _isUsingHardwareSensor ? Colors.teal : Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text(
                _sensorStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isUsingHardwareSensor ? Colors.teal : Colors.orange[800],
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 20),
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 13.0,
              animation: true,
              percent: _percent,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_walk, 
                    size: 50, 
                    color: _isUsingHardwareSensor ? Colors.teal : Colors.orange
                  ),
                  Text(
                    "$_todaySteps",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
                  ),
                  const Text("Langkah", style: TextStyle(color: Colors.grey)),
                ],
              ),
              footer: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "Target: $_targetSteps",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: _isUsingHardwareSensor ? Colors.teal : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
