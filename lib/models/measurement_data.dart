/// Represents a single measurement sample with timestamp and angles from both algorithms
class MeasurementData {
  final DateTime timestamp;
  final double algorithm1Angle; // Acceleration-based with EWMA filter
  final double algorithm2Angle; // Sensor fusion with complementary filter

  MeasurementData({
    required this.timestamp,
    required this.algorithm1Angle,
    required this.algorithm2Angle,
  });

  /// Convert to CSV row format
  String toCsvRow() {
    return '${timestamp.millisecondsSinceEpoch},$algorithm1Angle,$algorithm2Angle';
  }

  /// CSV header for export
  static String csvHeader() {
    return 'timestamp,alg1_angle,alg2_angle';
  }
}
