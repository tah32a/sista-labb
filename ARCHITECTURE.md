# Architecture Documentation

## Overview

This Flutter application follows a clean MVVM (Model-View-ViewModel) architecture with clear separation of concerns. The codebase is organized into distinct layers, each with specific responsibilities.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                         UI Layer                         │
│                   (views/ & widgets/)                    │
│  - HomeScreen: Main interface                            │
│  - MeasurementChart: Graph visualization                 │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│                    ViewModel Layer                       │
│                  (viewmodels/)                           │
│  - MeasurementViewModel: State management                │
│  - Coordinates services                                  │
│  - Notifies UI of state changes                          │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│                    Service Layer                         │
│                    (services/)                           │
│  - SensorService: Sensor data acquisition                │
│  - AlgorithmService: Angle computation                   │
│  - ExportService: CSV export                             │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│                     Model Layer                          │
│                     (models/)                            │
│  - MeasurementData: Processed measurement                │
│  - SensorReading: Raw sensor data                        │
└─────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Models (Data Layer)

#### MeasurementData
- **Purpose**: Represents a single processed measurement point
- **Contains**: Timestamp, Algorithm 1 angle, Algorithm 2 angle
- **Responsibilities**: 
  - Data structure for storing measurements
  - CSV formatting methods

#### SensorReading
- **Purpose**: Represents raw sensor data
- **Contains**: Timestamp, accelerometer (x,y,z), gyroscope (x,y,z)
- **Responsibilities**: 
  - Raw data encapsulation
  - Passes unprocessed sensor values to algorithms

### 2. Services (Business Logic Layer)

#### SensorService
- **Purpose**: Hardware sensor interaction
- **Responsibilities**:
  - Start/stop sensor listeners
  - Combine accelerometer and gyroscope data
  - Stream sensor readings
- **Dependencies**: sensors_plus package
- **Output**: Stream<SensorReading>

#### AlgorithmService
- **Purpose**: Angle computation algorithms
- **Responsibilities**:
  - **Algorithm 1**: Acceleration-based angle with EWMA filter
    - Computes angle from gravity vector
    - Applies exponential smoothing
    - Configurable α parameter (default 0.2)
  - **Algorithm 2**: Sensor fusion with complementary filter
    - Integrates gyroscope data
    - Combines with acceleration angle
    - Reduces drift using complementary filter (α ≈ 0.95)
  - State management for filter variables
- **Key Methods**:
  - `computeAlgorithm1Angle()`: Returns smoothed acceleration-based angle
  - `computeAlgorithm2Angle()`: Returns fused angle
  - `reset()`: Clears filter state

#### ExportService
- **Purpose**: Data export functionality
- **Responsibilities**:
  - Generate CSV formatted string
  - Write to file system
  - Return file path
- **Dependencies**: path_provider, dart:io

### 3. ViewModel (State Management Layer)

#### MeasurementViewModel
- **Purpose**: Centralized state management and service coordination
- **Extends**: ChangeNotifier (Flutter state management)
- **State Variables**:
  - `_isRecording`: Recording status
  - `_measurements`: List of all measurement points
  - `_currentMeasurement`: Latest measurement for display
- **Key Methods**:
  - `startMeasurement()`: Initiates recording
    - Clears previous data
    - Resets algorithms
    - Starts sensor stream
    - Subscribes to sensor data
  - `stopMeasurement()`: Ends recording
    - Stops sensor stream
    - Cancels subscriptions
  - `exportData()`: Exports to CSV
  - `_processSensorReading()`: Core processing pipeline
    - Receives sensor data
    - Computes both algorithm angles
    - Creates MeasurementData
    - Stores in list
    - Notifies UI
- **Coordination**:
  - Orchestrates SensorService, AlgorithmService, ExportService
  - Manages data flow from sensors → algorithms → storage
  - Notifies UI of state changes via ChangeNotifier

### 4. Views (UI Layer)

#### HomeScreen
- **Purpose**: Main application interface
- **Responsibilities**:
  - Display control buttons (Start, Stop, Export)
  - Show recording status
  - Display measurement chart
  - Show measurement statistics
  - Handle user interactions
- **State Management**: Listens to MeasurementViewModel
- **UI Components**:
  - Status indicator
  - Control buttons with enable/disable logic
  - Chart container
  - Info panel (samples, duration, current angles)

### 5. Widgets (Reusable UI Components)

#### MeasurementChart
- **Purpose**: Real-time and historical graph visualization
- **Responsibilities**:
  - Display dual-algorithm line chart
  - Show legend
  - Configure axes and labels
  - Enable touch interactions
- **Dependencies**: fl_chart package
- **Features**:
  - Two series (Algorithm 1: blue, Algorithm 2: red)
  - Real-time updates during recording
  - Smooth curves
  - Touch tooltips
  - Grid lines for readability

## Data Flow

### Recording Flow
```
User Press Start
    ↓
MeasurementViewModel.startMeasurement()
    ↓
SensorService.startListening()
    ↓
[Continuous Stream]
    ↓
SensorReading → AlgorithmService
    ↓
Algorithm1Angle + Algorithm2Angle
    ↓
MeasurementData created
    ↓
Stored in ViewModel._measurements
    ↓
notifyListeners() called
    ↓
HomeScreen rebuilds
    ↓
MeasurementChart updates
```

### Export Flow
```
User Press Export
    ↓
MeasurementViewModel.exportData()
    ↓
ExportService.exportToCsv()
    ↓
Convert measurements to CSV format
    ↓
Write to file system
    ↓
Return file path
    ↓
Show success message in UI
```

## Algorithm Details

### Algorithm 1: EWMA Filter

**Purpose**: Smooth acceleration-based angle to reduce sensor noise

**Process**:
1. Calculate raw angle from acceleration vector
   - Uses arctangent of Z/Y components
   - Assumes phone aligned with arm
2. Apply EWMA filter: `y(n) = α·x(n) + (1-α)·y(n-1)`
   - α = 0.2 (default): 20% new value, 80% previous
   - Low α = more smoothing, slower response
   - High α = less smoothing, faster response

**Characteristics**:
- Simple and efficient
- Good noise reduction
- Introduces lag
- No drift accumulation

### Algorithm 2: Complementary Filter

**Purpose**: Combine gyroscope precision with accelerometer stability

**Process**:
1. Calculate acceleration-based angle (same as Algorithm 1)
2. Integrate gyroscope to get angle change
   - Convert rad/s to degrees
   - Multiply by time delta (dt)
   - Accumulate in `_gyroIntegratedAngle`
3. Apply complementary filter: `y(n) = α·x_acc + (1-α)·x_gyro`
   - α = 0.95: Favor acceleration 95%, gyro 5%
   - High α corrects gyro drift with gravity reference
   - Low (1-α) maintains gyro responsiveness
4. Update gyro angle with fused result to prevent long-term drift

**Characteristics**:
- More responsive than Algorithm 1
- Better tracking of rapid movements
- Drift correction via acceleration
- Slightly more complex

## Design Patterns

### 1. Service Pattern
- Services encapsulate specific functionality
- Services are stateless or manage internal state only
- Services have clear, focused responsibilities

### 2. Observer Pattern (ChangeNotifier)
- ViewModel notifies UI of state changes
- UI listens and rebuilds automatically
- Decouples state logic from presentation

### 3. Stream Pattern
- SensorService uses Dart streams
- Real-time data propagation
- Subscription-based processing

### 4. Repository Pattern (implied)
- ExportService acts as data persistence layer
- Abstracts file system operations
- Could be extended for database storage

## Code Organization Benefits

### Separation of Concerns
- Each layer has distinct responsibility
- Easy to locate and modify specific functionality
- Changes in one layer minimally impact others

### Testability
- Services can be unit tested independently
- ViewModels can be tested without UI
- Mock services for testing

### Maintainability
- Clear structure for new developers
- Well-documented responsibilities
- Consistent naming conventions

### Scalability
- Easy to add new algorithms (in AlgorithmService)
- Can extend with database (new service)
- Can add more views without affecting logic

## Key Classes Responsibility Summary

| Class | Layer | Primary Responsibility |
|-------|-------|------------------------|
| `MeasurementData` | Model | Data structure for processed measurements |
| `SensorReading` | Model | Data structure for raw sensor data |
| `SensorService` | Service | Acquire sensor data from hardware |
| `AlgorithmService` | Service | Compute elevation angles using two algorithms |
| `ExportService` | Service | Export data to CSV files |
| `MeasurementViewModel` | ViewModel | Coordinate services, manage state, notify UI |
| `HomeScreen` | View | Main UI, handle user interactions |
| `MeasurementChart` | Widget | Visualize measurement data as graph |

## Configuration

### Adjustable Parameters

#### EWMA Alpha (Algorithm 1)
- Default: 0.2
- Range: 0.0 - 1.0
- Location: `AlgorithmService._ewmaAlpha`
- Method: `setEwmaAlpha(double alpha)`

#### Complementary Filter Alpha (Algorithm 2)
- Default: 0.95
- Fixed (can be made configurable)
- Location: `AlgorithmService._complementaryAlpha`

## Future Extension Points

1. **Add Database Storage**: Create DatabaseService in services/
2. **Add More Algorithms**: Extend AlgorithmService
3. **Add Settings Screen**: Create SettingsViewModel and SettingsScreen
4. **Add Historical View**: New screen to browse past measurements
5. **Add Calibration**: Calibration service for sensor offset correction
6. **Add Bluetooth Export**: Bluetooth service for wireless data transfer

## Dependencies

- **sensors_plus**: Sensor data acquisition
- **fl_chart**: Professional charting
- **path_provider**: File system access
- **csv**: CSV formatting (used manually)
- **permission_handler**: Runtime permissions (future use)

## Notes

- No god classes: Each class has focused responsibility
- Clear naming: Methods and variables describe their purpose
- Comprehensive comments: All classes and key methods documented
- Type safety: Strong typing throughout
- Error handling: Try-catch in critical paths
- Resource management: Proper disposal of streams and subscriptions
