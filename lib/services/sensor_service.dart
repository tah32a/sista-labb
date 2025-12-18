import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_reading.dart';

class SensorService {
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  double _gyroZ = 0.0;

  final StreamController<SensorReading> _sensorStreamController =
      StreamController<SensorReading>.broadcast();

  Stream<SensorReading> get sensorStream => _sensorStreamController.stream;

  void startListening() {
    _accelSubscription = userAccelerometerEventStream().listen((event) {
      _accelX = event.x;
      _accelY = event.y;
      _accelZ = event.z;
      _emitCombinedReading();
    });

    _gyroSubscription = gyroscopeEventStream().listen((event) {
      _gyroX = event.x;
      _gyroY = event.y;
      _gyroZ = event.z;
      _emitCombinedReading();
    });
  }

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

  void stopListening() {
    _accelSubscription?.cancel();
    _gyroSubscription?.cancel();
  }

  void dispose() {
    stopListening();
    _sensorStreamController.close();
  }
}
