import 'dart:math';
import '../models/sensor_reading.dart';

/// Service containing the two angle computation algorithms
class AlgorithmService {
  // Algorithm 1: EWMA filter parameters
  double _ewmaAlpha = 0.2; // Configurable smoothing factor
  double _ewmaPreviousAngle = 0.0;

  // Algorithm 2: Complementary filter parameters
  final double _complementaryAlpha = 0.95; // Favor acceleration over gyro
  double _gyroIntegratedAngle = 0.0;
  DateTime? _previousTimestamp;

  /// Set EWMA alpha parameter (0-1)
  void setEwmaAlpha(double alpha) {
    _ewmaAlpha = alpha.clamp(0.0, 1.0);
  }

  /// Algorithm 1: Compute elevation angle from acceleration with EWMA filter
  /// Returns angle in degrees (0-90)
  double computeAlgorithm1Angle(SensorReading reading) {
    // Calculate raw angle from acceleration
    // Assuming phone is held along the arm, Y-axis points along arm length
    // Z-axis is perpendicular (gravity component changes with elevation)
    double rawAngle = _computeAngleFromAcceleration(
      reading.accelX,
      reading.accelY,
      reading.accelZ,
    );

    // Apply EWMA filter: y(n) = α·x(n) + (1-α)·y(n-1)
    double filteredAngle = _ewmaAlpha * rawAngle + (1 - _ewmaAlpha) * _ewmaPreviousAngle;
    _ewmaPreviousAngle = filteredAngle;

    return filteredAngle;
  }

  /// Algorithm 2: Sensor fusion using complementary filter
  /// Combines gyroscope integration with acceleration-based angle
  /// Returns angle in degrees (0-90)
  double computeAlgorithm2Angle(SensorReading reading) {
    // Get acceleration-based angle
    double accelAngle = _computeAngleFromAcceleration(
      reading.accelX,
      reading.accelY,
      reading.accelZ,
    );

    // Integrate gyroscope to get angle change
    if (_previousTimestamp != null) {
      double dt = reading.timestamp.difference(_previousTimestamp!).inMicroseconds / 1000000.0;
      
      // Integrate gyro (assuming rotation around X-axis for arm abduction)
      // Use gyroX for lateral arm movement (abduction/adduction)
      double gyroAngleChange = reading.gyroX * dt * (180.0 / pi); // Convert rad/s to degrees
      _gyroIntegratedAngle += gyroAngleChange;
    }

    _previousTimestamp = reading.timestamp;

    // Apply complementary filter: y(n) = α·x_acc + (1-α)·x_gyro
    // High α (0.95) favors acceleration to correct gyro drift
    double fusedAngle = _complementaryAlpha * accelAngle + (1 - _complementaryAlpha) * _gyroIntegratedAngle;
    
    // Update gyro angle with fused result to prevent long-term drift
    _gyroIntegratedAngle = fusedAngle;

    return fusedAngle;
  }

  /// Compute elevation angle from acceleration vector
  /// Returns angle in degrees (0-90)
  double _computeAngleFromAcceleration(double x, double y, double z) {
    // Calculate the magnitude of acceleration
    double magnitude = sqrt(x * x + y * y + z * z);
    
    if (magnitude < 0.1) {
      return 0.0; // Avoid division by zero
    }

    // Assuming phone is held with Y-axis along arm
    // When arm is at 0° (vertical down), gravity is primarily in -Y direction
    // When arm is at 90° (horizontal), gravity is primarily in -Z direction
    // Calculate angle from vertical using Z and Y components
    double angle = atan2(z.abs(), y.abs()) * (180.0 / pi);
    
    // Clamp to 0-90 degrees
    return angle.clamp(0.0, 90.0);
  }

  /// Reset algorithm states (call when starting new measurement)
  void reset() {
    _ewmaPreviousAngle = 0.0;
    _gyroIntegratedAngle = 0.0;
    _previousTimestamp = null;
  }
}
