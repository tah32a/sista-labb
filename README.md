# Arm Elevation Tracker

A Flutter mobile application for measuring arm elevation (0-90 degrees) during abduction and adduction movements using internal phone sensors.

## Features

- **Real-time measurement**: Records arm elevation using accelerometer and gyroscope
- **Dual algorithm approach**:
  - Algorithm 1: Acceleration-based with EWMA filtering
  - Algorithm 2: Sensor fusion with complementary filter
- **Live visualization**: Continuous graph updates during recording
- **CSV export**: Export data with timestamp, alg1_angle, alg2_angle format
- **Clean MVVM architecture**: Separated concerns for maintainability

## Architecture

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── measurement_data.dart          # Measurement data point
│   └── sensor_reading.dart            # Raw sensor data
├── services/                          # Business logic layer
│   ├── sensor_service.dart            # Sensor data acquisition
│   ├── algorithm_service.dart         # Angle computation algorithms
│   └── export_service.dart            # CSV export functionality
├── viewmodels/                        # State management
│   └── measurement_viewmodel.dart     # Measurement coordination
├── views/                             # UI screens
│   └── home_screen.dart               # Main screen
└── widgets/                           # Reusable components
    └── measurement_chart.dart         # Chart visualization
```

## Algorithms

### Algorithm 1: EWMA Filter
- Computes elevation angle from linear acceleration
- Applies Exponentially Weighted Moving Average (EWMA) filter
- Formula: `y(n) = α·x(n) + (1-α)·y(n-1)`
- Default α = 0.2 (configurable)

### Algorithm 2: Sensor Fusion
- Integrates gyroscope data to compute angle
- Combines with acceleration-based angle using complementary filter
- Formula: `y(n) = α·x_acc + (1-α)·x_gyro`
- α ≈ 0.95 to reduce gyro drift while maintaining responsiveness

## Usage

1. **Start Measurement**: Press the green "Start" button to begin recording
2. **Perform Movement**: Move your arm from 0° to 90° and back to 0°
   - Slow movement: ~10 seconds
   - Fast movement: ~1 second
3. **Stop Measurement**: Press the red "Stop" button to end recording
4. **View Results**: The graph displays both algorithm outputs
5. **Export Data**: Press the blue "Export" button to save CSV file

## CSV Export Format

```csv
timestamp,alg1_angle,alg2_angle
1702819200000,0.0,0.0
1702819200100,5.2,4.8
...
```

- `timestamp`: Milliseconds since epoch
- `alg1_angle`: Algorithm 1 angle (degrees)
- `alg2_angle`: Algorithm 2 angle (degrees)

## Installation

1. Ensure Flutter is installed (SDK >=3.0.0)
2. Navigate to project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- **sensors_plus**: Sensor data acquisition
- **fl_chart**: Graph visualization
- **csv**: CSV file generation
- **path_provider**: File system access
- **permission_handler**: Storage permissions

## Requirements

- Flutter SDK 3.0.0 or higher
- Android 5.0+ / iOS 12.0+
- Device with accelerometer and gyroscope sensors
- Storage permission for CSV export

## Limitations

- No Bluetooth connectivity
- No local database storage
- No background recording
- Requires manual measurement start/stop

## License

This project is created for educational/research purposes.
