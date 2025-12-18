import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/measurement_data.dart';

class ExportService {
  Future<String> exportToCsv(List<MeasurementData> measurements) async {
    if (measurements.isEmpty) {
      throw Exception('No data to export');
    }

    final directory = await getExternalStorageDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory!.path}/arm_elevation_$timestamp.csv';

    final csvBuffer = StringBuffer();
    csvBuffer.writeln(MeasurementData.csvHeader());

    for (var measurement in measurements) {
      csvBuffer.writeln(measurement.toCsvRow());
    }

    final file = File(filePath);
    await file.writeAsString(csvBuffer.toString());

    return filePath;
  }
}
