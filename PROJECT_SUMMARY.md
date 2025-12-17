# Arm Elevation Tracker - Project Summary

## Project Overview

A complete Flutter mobile application for measuring arm elevation (0-90 degrees) during abduction and adduction movements using internal phone sensors (accelerometer and gyroscope).

## ✅ Requirements Fulfilled

### Core Functionality
- ✅ Measures arm elevation 0-90 degrees during abduction/adduction
- ✅ Uses only internal sensors (linear acceleration + gyroscope)
- ✅ Records 10-30 second measurements
- ✅ Supports slow (~10s) and fast (~1s) movements
- ✅ Real-time angle computation

### User Interface
- ✅ Home screen with three buttons:
  - Start Measurement (green)
  - Stop Measurement (red)
  - Export CSV (blue)
- ✅ Live graph displaying both algorithms simultaneously
- ✅ Graph persists after stopping
- ✅ Real-time angle display during recording
- ✅ Recording status indicator
- ✅ Measurement statistics (samples, duration, current angles)

### Algorithm 1: EWMA Filter
- ✅ Computes elevation from linear acceleration
- ✅ Applies EWMA filter: y(n) = α·x(n) + (1-α)·y(n-1)
- ✅ Configurable α parameter (default 0.2)
- ✅ Smooth angle output with noise reduction

### Algorithm 2: Sensor Fusion
- ✅ Integrates gyroscope data to angle
- ✅ Combines with acceleration angle
- ✅ Complementary filter: y(n) = α·x_acc + (1-α)·x_gyro
- ✅ α ≈ 0.95 for drift reduction
- ✅ Responsive tracking with drift correction

### Data Recording & Export
- ✅ Stores timestamp, alg1_angle, alg2_angle for each sample
- ✅ Exports to CSV with header: timestamp,alg1_angle,alg2_angle
- ✅ Compatible with Excel for plotting
- ✅ Timestamp in milliseconds since epoch

### Architecture
- ✅ Clean MVVM-style separation
- ✅ Separated layers:
  - Models (data structures)
  - Services (sensor acquisition, algorithms, export)
  - ViewModel (state management)
  - Views/Widgets (UI)
- ✅ No god classes
- ✅ Clear naming and comprehensive comments
- ✅ Focused responsibilities per class

### Technical Requirements
- ✅ Fully compilable Flutter application
- ✅ Uses sensors_plus plugin for sensors
- ✅ Uses fl_chart for live graphing
- ✅ Uses path_provider for file access
- ✅ No Bluetooth support
- ✅ No local database
- ✅ No background recording
- ✅ Complete source code ready for submission

## 📁 Project Structure

```
lab-sist/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── models/                            # Data models
│   │   ├── measurement_data.dart          # Processed measurement point
│   │   └── sensor_reading.dart            # Raw sensor data
│   ├── services/                          # Business logic
│   │   ├── sensor_service.dart            # Sensor acquisition
│   │   ├── algorithm_service.dart         # Angle computation
│   │   └── export_service.dart            # CSV export
│   ├── viewmodels/                        # State management
│   │   └── measurement_viewmodel.dart     # Measurement coordinator
│   ├── views/                             # UI screens
│   │   └── home_screen.dart               # Main interface
│   └── widgets/                           # Reusable components
│       └── measurement_chart.dart         # Graph visualization
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml            # Android permissions
├── ios/
│   └── Runner/
│       ├── Info.plist                     # iOS permissions
│       └── AppDelegate.swift              # iOS app delegate
├── pubspec.yaml                           # Dependencies
├── analysis_options.yaml                  # Linter configuration
├── README.md                              # Project documentation
├── ARCHITECTURE.md                        # Architecture details
└── TESTING_GUIDE.md                       # Testing instructions
```

## 🔧 Key Components

### SensorService
- Acquires accelerometer and gyroscope data
- Combines into unified sensor readings
- Provides stream of sensor data

### AlgorithmService
- Implements Algorithm 1 (EWMA filter)
- Implements Algorithm 2 (Sensor fusion)
- Manages filter state variables
- Provides angle reset functionality

### MeasurementViewModel
- Coordinates all services
- Manages recording state
- Stores measurement data
- Notifies UI of changes
- Handles start/stop/export operations

### HomeScreen
- Main UI with control buttons
- Displays recording status
- Shows measurement chart
- Presents real-time statistics
- Handles user interactions

### MeasurementChart
- Live/historical graph visualization
- Dual-algorithm line chart
- Blue line: Algorithm 1
- Red line: Algorithm 2
- Interactive tooltips

## 📊 Algorithms Explained

### Algorithm 1: EWMA Filter
```
1. Calculate angle from acceleration vector
2. Apply EWMA: y(n) = 0.2·x(n) + 0.8·y(n-1)
3. Result: Smooth, lag-prone angle
```

**Characteristics:**
- Reduces noise effectively
- Introduces lag in response
- No drift accumulation
- Good for steady movements

### Algorithm 2: Complementary Filter
```
1. Calculate angle from acceleration
2. Integrate gyroscope: angle += gyro * dt
3. Fuse: y(n) = 0.95·accel_angle + 0.05·gyro_angle
4. Update gyro angle to prevent drift
```

**Characteristics:**
- Responsive to quick movements
- Corrects gyro drift with accel
- Better tracking of dynamics
- Slightly more complex

## 🚀 Quick Start

```bash
# Navigate to project
cd /Users/tah42a/lab-sist

# Install dependencies
flutter pub get

# Verify no issues
flutter analyze

# Connect device and run
flutter run
```

## 📱 Usage

1. **Start Recording**: Press green "Start" button
2. **Perform Movement**: Move arm from 0° to 90° and back
3. **Stop Recording**: Press red "Stop" button
4. **View Results**: Graph shows both algorithm outputs
5. **Export Data**: Press blue "Export" button to save CSV

## 📈 CSV Export Format

```csv
timestamp,alg1_angle,alg2_angle
1702819200000,0.0,0.0
1702819200100,5.2,4.8
1702819200200,10.5,10.1
...
```

- **timestamp**: Milliseconds since epoch
- **alg1_angle**: Algorithm 1 angle (degrees, 0-90)
- **alg2_angle**: Algorithm 2 angle (degrees, 0-90)

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| sensors_plus | ^4.0.2 | Sensor data acquisition |
| fl_chart | ^0.66.0 | Graph visualization |
| csv | ^6.0.0 | CSV formatting |
| path_provider | ^2.1.2 | File system access |
| permission_handler | ^11.3.0 | Runtime permissions |

## ✨ Features

- **Real-time Visualization**: Live graph updates during recording
- **Dual Algorithm Comparison**: See both algorithms simultaneously
- **Clean Architecture**: MVVM with clear separation
- **Export to Excel**: CSV format compatible with spreadsheets
- **Responsive UI**: Material Design 3
- **Efficient Processing**: Handles 50-100 Hz sensor rates
- **No External Dependencies**: Works standalone, no cloud/BT
- **Well Documented**: Comprehensive comments and guides

## 📝 Documentation

- **README.md**: User-facing documentation and setup
- **ARCHITECTURE.md**: Detailed architecture and design patterns
- **TESTING_GUIDE.md**: Step-by-step testing procedures
- **Inline Comments**: Every class and key method documented

## 🎯 Testing Scenarios

### Scenario 1: Slow Movement (10s)
- Smooth 0° → 90° → 0° over 10 seconds
- Both algorithms should track closely
- Algorithm 1 shows smoother line

### Scenario 2: Fast Movement (1s)
- Rapid 0° → 90° → 0° over 1 second
- Algorithm 2 more responsive
- Algorithm 1 shows lag due to filtering

### Scenario 3: Export Validation
- CSV file created with correct format
- Data matches graph visualization
- Can be opened in Excel for plotting

## 🔒 Scope Limitations (As Required)

- ❌ No Bluetooth connectivity
- ❌ No local database storage
- ❌ No background recording
- ❌ No cloud sync
- ❌ No user authentication

## ✅ Code Quality

- **No Errors**: `flutter analyze` passes with 0 issues
- **Type Safety**: Full Dart type checking
- **Clean Code**: Consistent formatting
- **Best Practices**: Flutter and Dart conventions
- **Resource Management**: Proper disposal of streams/subscriptions
- **Error Handling**: Try-catch in critical sections

## 🎓 Learning Resources

The code demonstrates:
- MVVM architecture pattern
- Stream-based data flow
- State management with ChangeNotifier
- Sensor data processing
- Digital signal processing (EWMA, complementary filter)
- Real-time chart visualization
- File I/O operations
- Flutter best practices

## 📞 Support

Refer to documentation files:
- Setup issues → README.md
- Architecture questions → ARCHITECTURE.md
- Testing procedures → TESTING_GUIDE.md

## 🏁 Submission Checklist

- ✅ Complete source code
- ✅ Compiles without errors
- ✅ All requirements implemented
- ✅ MVVM architecture
- ✅ Clear comments and naming
- ✅ Documentation files
- ✅ Testing guide
- ✅ Ready to run on physical device
- ✅ CSV export functional
- ✅ No out-of-scope features

---

**Status**: ✅ **COMPLETE AND READY FOR SUBMISSION**

All requirements have been fully implemented. The application is compilable, runnable, and ready for testing on a physical device with accelerometer and gyroscope sensors.
