import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_reading.dart';

/// Service responsible for acquiring sensor data from accelerometer and gyroscope
class SensorService {
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  // Latest sensor values
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  double _gyroZ = 0.0;

  final StreamController<SensorReading> _sensorStreamController =
      StreamController<SensorReading>.broadcast();

  /// Stream of combined sensor readings
  Stream<SensorReading> get sensorStream => _sensorStreamController.stream;

  /// Start listening to accelerometer and gyroscope sensors
  void startListening() {
    // Listen to linear accelerometer (if available, otherwise use regular accelerometer)
    _accelSubscription = userAccelerometerEventStream().listen((event) {
      _accelX = event.x;
      _accelY = event.y;
      _accelZ = event.z;
      _emitCombinedReading();
    });

    // Listen to gyroscope
    _gyroSubscription = gyroscopeEventStream().listen((event) {
      _gyroX = event.x;
      _gyroY = event.y;
      _gyroZ = event.z;
      _emitCombinedReading();
    });
  }

  /// Emit combined sensor reading
  void _emitCombinedReading() {
    _sensorStreamController.add(SensorReading(
      timestamp: DateTime.now(),
      accelX: _accelX,
      accelY: _accelY,
      accelZ: _accelZ,
      gyroX: _gyroX,
      gyroY: _gyroY,
      gyroZ: _gyroZ,
    ));
  }

  /// Stop listening to sensors
  void stopListening() {
    _accelSubscription?.cancel();
    _gyroSubscription?.cancel();
  }

  /// Dispose resources
  void dispose() {
    stopListening();
    _sensorStreamController.close();
  }
}
