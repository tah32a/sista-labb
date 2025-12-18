class MeasurementData {
  final DateTime timestamp;
  final double algorithm1Angle;
  final double algorithm2Angle;

  MeasurementData({
    required this.timestamp,
    required this.algorithm1Angle,
    required this.algorithm2Angle,
  });

  String toCsvRow() {
    return '${timestamp.millisecondsSinceEpoch},$algorithm1Angle,$algorithm2Angle';
  }

  static String csvHeader() {
    return 'timestamp,alg1_angle,alg2_angle';
  }
}
