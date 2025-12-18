import 'dart:math';
import '../models/sensor_reading.dart';

class AlgorithmService {
  double _ewmaAlpha = 0.2;
  double _ewmaPreviousAngle = 0.0;

  final double _complementaryAlpha = 0.95;
  double _gyroIntegratedAngle = 0.0;
  DateTime? _previousTimestamp;

  void setEwmaAlpha(double alpha) {
    _ewmaAlpha = alpha.clamp(0.0, 1.0);
  }

  // Algorithm 1: EWMA filter
  double computeAlgorithm1Angle(SensorReading reading) {
    double rawAngle = _computeAngleFromAcceleration(
      reading.accelX,
      reading.accelY,
      reading.accelZ,
    );

    // y(n) = α·x(n) + (1-α)·y(n-1)
    double filteredAngle =
        _ewmaAlpha * rawAngle + (1 - _ewmaAlpha) * _ewmaPreviousAngle;
    _ewmaPreviousAngle = filteredAngle;

    return filteredAngle;
  }

  // Algorithm 2: Complementary filter with sensor fusion
  double computeAlgorithm2Angle(SensorReading reading) {
    double accelAngle = _computeAngleFromAcceleration(
      reading.accelX,
      reading.accelY,
      reading.accelZ,
    );

    if (_previousTimestamp != null) {
      double dt =
          reading.timestamp.difference(_previousTimestamp!).inMicroseconds /
              1000000.0;
      double gyroAngleChange = reading.gyroX * dt * (180.0 / pi);
      _gyroIntegratedAngle += gyroAngleChange;
    }

    _previousTimestamp = reading.timestamp;

    // y(n) = α·x_acc + (1-α)·x_gyro
    double fusedAngle = _complementaryAlpha * accelAngle +
        (1 - _complementaryAlpha) * _gyroIntegratedAngle;
    _gyroIntegratedAngle = fusedAngle;

    return fusedAngle;
  }

  double _computeAngleFromAcceleration(double x, double y, double z) {
    double magnitude = sqrt(x * x + y * y + z * z);

    if (magnitude < 0.1) {
      return 0.0;
    }

    double angle = atan2(z.abs(), y.abs()) * (180.0 / pi);
    return angle.clamp(0.0, 90.0);
  }

  void reset() {
    _ewmaPreviousAngle = 0.0;
    _gyroIntegratedAngle = 0.0;
    _previousTimestamp = null;
  }
}
