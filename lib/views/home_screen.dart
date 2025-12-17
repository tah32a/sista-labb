import 'package:flutter/material.dart';
import '../viewmodels/measurement_viewmodel.dart';
import '../widgets/measurement_chart.dart';

/// Home screen with measurement controls and live/historical graph display
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MeasurementViewModel _viewModel = MeasurementViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {}); // Rebuild UI when ViewModel changes
  }

  void _startMeasurement() {
    _viewModel.startMeasurement();
  }

  void _stopMeasurement() {
    _viewModel.stopMeasurement();
  }

  Future<void> _exportData() async {
    if (!_viewModel.hasData) {
      _showMessage('No data to export');
      return;
    }

    final filePath = await _viewModel.exportData();
    if (filePath != null) {
      _showMessage('Data exported to:\n$filePath');
    } else {
      _showMessage('Export failed');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arm Elevation Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Control buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: _viewModel.isRecording
                          ? Colors.red.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _viewModel.isRecording
                              ? Icons.fiber_manual_record
                              : Icons.stop_circle_outlined,
                          color: _viewModel.isRecording ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _viewModel.isRecording ? 'Recording...' : 'Stopped',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button row
                  Row(
                    children: [
                      // Start button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _viewModel.isRecording ? null : _startMeasurement,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Stop button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _viewModel.isRecording ? _stopMeasurement : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Export button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _viewModel.hasData ? _exportData : null,
                          icon: const Icon(Icons.download),
                          label: const Text('Export'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chart display
            Expanded(
              child: _viewModel.hasData
                  ? MeasurementChart(measurements: _viewModel.measurements)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No data yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Press Start to begin measurement',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Data info
            if (_viewModel.hasData)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(
                      'Samples',
                      _viewModel.measurements.length.toString(),
                    ),
                    _buildInfoItem(
                      'Duration',
                      _getDuration(),
                    ),
                    _buildInfoItem(
                      'Alg 1',
                      _viewModel.currentMeasurement?.algorithm1Angle
                              .toStringAsFixed(1) ??
                          '-',
                    ),
                    _buildInfoItem(
                      'Alg 2',
                      _viewModel.currentMeasurement?.algorithm2Angle
                              .toStringAsFixed(1) ??
                          '-',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getDuration() {
    if (_viewModel.measurements.isEmpty) return '-';
    
    final first = _viewModel.measurements.first.timestamp;
    final last = _viewModel.measurements.last.timestamp;
    final duration = last.difference(first).inSeconds;
    
    return '${duration}s';
  }
}
