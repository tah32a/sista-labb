import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/measurement_data.dart';
import '../models/sensor_reading.dart';
import '../services/sensor_service.dart';
import '../services/algorithm_service.dart';
import '../services/export_service.dart';

class MeasurementViewModel extends ChangeNotifier {
  final SensorService _sensorService = SensorService();
  final AlgorithmService _algorithmService = AlgorithmService();
  final ExportService _exportService = ExportService();

  StreamSubscription<SensorReading>? _sensorSubscription;

  bool _isRecording = false;
  final List<MeasurementData> _measurements = [];
  MeasurementData? _currentMeasurement;

  bool get isRecording => _isRecording;
  List<MeasurementData> get measurements => List.unmodifiable(_measurements);
  MeasurementData? get currentMeasurement => _currentMeasurement;
  bool get hasData => _measurements.isNotEmpty;

  void startMeasurement() {
    if (_isRecording) return;

    _measurements.clear();
    _currentMeasurement = null;
    _algorithmService.reset();

    _sensorService.startListening();
    _isRecording = true;

    _sensorSubscription =
        _sensorService.sensorStream.listen(_processSensorReading);

    notifyListeners();
  }

  void stopMeasurement() {
    if (!_isRecording) return;

    _isRecording = false;
    _sensorSubscription?.cancel();
    _sensorService.stopListening();

    notifyListeners();
  }

  void _processSensorReading(SensorReading reading) {
    double alg1Angle = _algorithmService.computeAlgorithm1Angle(reading);
    double alg2Angle = _algorithmService.computeAlgorithm2Angle(reading);

    final measurement = MeasurementData(
      timestamp: reading.timestamp,
      algorithm1Angle: alg1Angle,
      algorithm2Angle: alg2Angle,
    );

    _measurements.add(measurement);
    _currentMeasurement = measurement;

    notifyListeners();
  }

  Future<String?> exportData() async {
    if (_measurements.isEmpty) {
      return null;
    }

    try {
      final filePath = await _exportService.exportToCsv(_measurements);
      return filePath;
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }

  void setEwmaAlpha(double alpha) {
    _algorithmService.setEwmaAlpha(alpha);
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}
