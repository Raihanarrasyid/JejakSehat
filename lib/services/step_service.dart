import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'api_service.dart';

class StepService extends ChangeNotifier {
  // --- STATE VARIABLES ---
  int _todaySteps = 0;
  int _targetSteps = 10000;
  double _percent = 0.0;
  String _sensorStatus = 'Menyiapkan Sensor...';
  bool _isUsingHardwareSensor = true;
  bool _hasShownCongratulation = false;

  // Getters untuk UI
  int get todaySteps => _todaySteps;
  int get targetSteps => _targetSteps;
  double get percent => _percent;
  String get sensorStatus => _sensorStatus;
  bool get isUsingHardwareSensor => _isUsingHardwareSensor;
  bool get hasShownCongratulation => _hasShownCongratulation;

  // Internal Logic
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  late SharedPreferences _prefs;
  int _stepsOffset = 0;
  String _lastSavedDate = "";
  
  // Accelerometer Logic
  double _previousMagnitude = 0;
  final double _threshold = 12.0;

  // --- INITIALIZATION ---
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadLocalData();
    await _requestPermission();
  }

  Future<void> _loadLocalData() async {
    _targetSteps = _prefs.getInt('daily_target') ?? 10000;
    
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _lastSavedDate = _prefs.getString('last_date') ?? today;
    _stepsOffset = _prefs.getInt('steps_offset') ?? 0;
    _hasShownCongratulation = _prefs.getBool('congrats_shown_$today') ?? false;

    _checkDailyReset(today);
  }

  Future<void> _requestPermission() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _initHardwarePedometer();
    } else {
      _sensorStatus = 'Izin sensor ditolak user';
      notifyListeners();
    }
  }

  // --- SENSOR LOGIC ---
  void _initHardwarePedometer() {
    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream!.listen(_onStepCount).onError((error) {
        _useAccelerometerFallback();
      });
    } catch (e) {
      _useAccelerometerFallback();
    }
  }

  void _useAccelerometerFallback() {
    _isUsingHardwareSensor = false;
    _sensorStatus = 'Mode Accelerometer (Manual)';
    
    // Load langkah manual terakhir
    _todaySteps = _prefs.getInt('manual_steps_today') ?? 0;
    _updateProgress();
    notifyListeners();

    _accelSubscription = userAccelerometerEvents.listen((event) {
      _detectStepFromAccel(event);
    });
  }

  void _onStepCount(StepCount event) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (today != _lastSavedDate) _checkDailyReset(today);

    bool needNewOffset = _prefs.getBool('need_new_offset') ?? false;
    if (needNewOffset || event.steps < _stepsOffset) {
      _stepsOffset = event.steps;
      _prefs.setInt('steps_offset', _stepsOffset);
      _prefs.setBool('need_new_offset', false);
    }

    _isUsingHardwareSensor = true;
    _sensorStatus = 'Mode Sensor Bawaan';
    
    int calculatedSteps = event.steps - _stepsOffset;
    _todaySteps = calculatedSteps < 0 ? 0 : calculatedSteps;
    
    _updateProgress();
    _saveLocalData(today);
    notifyListeners();
  }

  void _detectStepFromAccel(UserAccelerometerEvent event) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (today != _lastSavedDate) _checkDailyReset(today);

    double magnitude = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));

    if (magnitude > _threshold && _previousMagnitude <= _threshold) {
      _todaySteps++;
      _prefs.setInt('manual_steps_today', _todaySteps);
      _updateProgress();
      _saveLocalData(today);
      notifyListeners();
    }
    _previousMagnitude = magnitude;
  }

  // --- HELPER LOGIC ---
  void _updateProgress() {
    _percent = (_todaySteps / _targetSteps);
    if (_percent > 1.0) _percent = 1.0;
  }

  void _checkDailyReset(String todayDate) async {
    if (_lastSavedDate != todayDate) {
      // Sync Data Kemarin
      int yesterdaySteps = await _getYesterdayStepsFromDB(_lastSavedDate);
      if (yesterdaySteps > 0) {
        ApiService.syncDailySteps(_lastSavedDate, yesterdaySteps);
      }

      // Reset
      _todaySteps = 0;
      _stepsOffset = 0;
      _lastSavedDate = todayDate;
      _hasShownCongratulation = false;

      await _prefs.setString('last_date', todayDate);
      await _prefs.setInt('steps_offset', 0);
      await _prefs.setBool('congrats_shown_$todayDate', false);
      await _prefs.setInt('manual_steps_today', 0);
      await _prefs.setBool('need_new_offset', true);
      
      notifyListeners();
    }
  }

  Future<void> setTarget(int newTarget) async {
    _targetSteps = newTarget;
    _hasShownCongratulation = false; // Reset notifikasi
    _updateProgress();
    await _prefs.setInt('daily_target', newTarget);
    notifyListeners();
  }

  void markCongratulationShown() {
    _hasShownCongratulation = true;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _prefs.setBool('congrats_shown_$today', true);
    notifyListeners(); // Optional
  }

  Future<bool> forceSync() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await ApiService.syncDailySteps(today, _todaySteps);
  }

  Future<int> _getYesterdayStepsFromDB(String date) async {
    final dbData = await DatabaseHelper.instance.getHistory();
    for (var row in dbData) {
      if (row['date'] == date) return row['step_count'] as int;
    }
    return 0;
  }
  
  void _saveLocalData(String date) {
    DatabaseHelper.instance.insertOrUpdateStep(date, _todaySteps);
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    super.dispose();
  }
}