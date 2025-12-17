import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/measurement_data.dart';

/// Service responsible for exporting measurement data to CSV
class ExportService {
  /// Export measurement data to CSV file
  /// Returns the file path of the exported CSV
  Future<String> exportToCsv(List<MeasurementData> measurements) async {
    if (measurements.isEmpty) {
      throw Exception('No data to export');
    }

    // Get the directory for saving files
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/arm_elevation_$timestamp.csv';

    // Create CSV content
    final csvBuffer = StringBuffer();
    csvBuffer.writeln(MeasurementData.csvHeader());

    for (var measurement in measurements) {
      csvBuffer.writeln(measurement.toCsvRow());
    }

    // Write to file
    final file = File(filePath);
    await file.writeAsString(csvBuffer.toString());

    return filePath;
  }
}
