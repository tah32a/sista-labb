import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/measurement_data.dart';

/// Widget displaying live/historical chart of elevation angles from both algorithms
class MeasurementChart extends StatelessWidget {
  final List<MeasurementData> measurements;

  const MeasurementChart({
    super.key,
    required this.measurements,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Algorithm 1 (EWMA)', Colors.blue),
              const SizedBox(width: 24),
              _buildLegendItem('Algorithm 2 (Fusion)', Colors.red),
            ],
          ),
          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: LineChart(
              _buildChartData(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  LineChartData _buildChartData() {
    // Prepare data points
    final startTime = measurements.first.timestamp.millisecondsSinceEpoch;
    
    final alg1Spots = measurements.asMap().entries.map((entry) {
      final timeOffset = (entry.value.timestamp.millisecondsSinceEpoch - startTime) / 1000.0;
      return FlSpot(timeOffset, entry.value.algorithm1Angle);
    }).toList();

    final alg2Spots = measurements.asMap().entries.map((entry) {
      final timeOffset = (entry.value.timestamp.millisecondsSinceEpoch - startTime) / 1000.0;
      return FlSpot(timeOffset, entry.value.algorithm2Angle);
    }).toList();

    return LineChartData(
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 15,
        verticalInterval: 5,
      ),
      titlesData: const FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: Text('Time (s)'),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 5,
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text('Angle (°)'),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 15,
            reservedSize: 40,

          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.shade300),
      ),
      minX: 0,
      maxX: alg1Spots.isNotEmpty ? alg1Spots.last.x : 10,
      minY: 0,
      maxY: 90,
      lineBarsData: [
        // Algorithm 1 line
        LineChartBarData(
          spots: alg1Spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
        // Algorithm 2 line
        LineChartBarData(
          spots: alg2Spots,
          isCurved: true,
          color: Colors.red,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final color = spot.bar.color ?? Colors.grey;
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)}°',
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
