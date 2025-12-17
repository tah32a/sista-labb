# App Flow Diagram

## UI Flow

```
┌─────────────────────────────────────────────────┐
│              HOME SCREEN                        │
│                                                 │
│  ┌─────────────────────────────────────┐       │
│  │  Status: [Recording... / Stopped]    │       │
│  └─────────────────────────────────────┘       │
│                                                 │
│  ┌────────┐  ┌────────┐  ┌────────────┐       │
│  │ START  │  │  STOP  │  │   EXPORT   │       │
│  │ (green)│  │  (red) │  │   (blue)   │       │
│  └────────┘  └────────┘  └────────────┘       │
│                                                 │
│  ┌─────────────────────────────────────┐       │
│  │         MEASUREMENT CHART            │       │
│  │                                      │       │
│  │  90° ┤          /\                  │       │
│  │      │         /  \                 │       │
│  │  45° ┤        /    \                │       │
│  │      │       /      \               │       │
│  │   0° └──────/────────\─────────     │       │
│  │        0s    5s    10s              │       │
│  │                                      │       │
│  │  Legend: ─ Alg 1  ─ Alg 2           │       │
│  └─────────────────────────────────────┘       │
│                                                 │
│  Samples: 856  Duration: 10s                   │
│  Alg 1: 45.2°  Alg 2: 46.8°                    │
└─────────────────────────────────────────────────┘
```

## Data Flow

```
┌──────────────────┐
│  Accelerometer   │
│  Gyroscope       │
│  (Hardware)      │
└────────┬─────────┘
         │
         ↓
┌──────────────────┐
│  SensorService   │
│  - Read sensors  │
│  - Combine data  │
└────────┬─────────┘
         │
         ↓
┌──────────────────┐
│ SensorReading    │
│ (x,y,z accel)    │
│ (x,y,z gyro)     │
└────────┬─────────┘
         │
         ↓
┌──────────────────────────────────────┐
│      AlgorithmService                │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  Algorithm 1: EWMA Filter      │ │
│  │  - Angle from accel            │ │
│  │  - Apply smoothing             │ │
│  │  → Smoothed angle              │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  Algorithm 2: Sensor Fusion    │ │
│  │  - Integrate gyro              │ │
│  │  - Combine with accel          │ │
│  │  → Fused angle                 │ │
│  └────────────────────────────────┘ │
└────────┬─────────────────────────────┘
         │
         ↓
┌──────────────────┐
│ MeasurementData  │
│ - timestamp      │
│ - alg1_angle     │
│ - alg2_angle     │
└────────┬─────────┘
         │
         ↓
┌──────────────────────────┐
│  MeasurementViewModel    │
│  - Store in list         │
│  - Notify UI             │
└────────┬─────────────────┘
         │
         ↓
┌──────────────────┐
│  HomeScreen      │
│  - Update graph  │
│  - Show stats    │
└──────────────────┘
```

## Algorithm Comparison

```
Movement: Arm 0° → 90° → 0°

Algorithm 1 (EWMA):
Angle
 90° ┤      ╱───╲
     │     ╱     ╲
 45° ┤   ╱         ╲
     │  ╱           ╲
  0° └─╯─────────────╲───
     0s  2s  4s  6s  8s 10s
     
Characteristics:
- Smooth curve
- Slight lag
- Less noise

Algorithm 2 (Fusion):
Angle
 90° ┤     ╱\
     │    ╱  \
 45° ┤   ╱    \
     │  ╱      \
  0° └─╯────────\────
     0s  2s  4s  6s  8s 10s
     
Characteristics:
- Sharp peaks
- More responsive
- Slight overshoot
```

## Recording Process

```
┌─────────────┐
│  Press      │
│  START      │
└──────┬──────┘
       │
       ↓
┌─────────────────────┐
│ Clear old data      │
│ Reset algorithms    │
│ Start sensors       │
└──────┬──────────────┘
       │
       ↓
┌─────────────────────┐
│ [Every ~10-20ms]    │
│ Read sensor         │
│ Compute angles      │
│ Store data point    │
│ Update graph        │
└──────┬──────────────┘
       │
       │ (continuous loop)
       │
       ↓
┌─────────────────────┐
│  Press              │
│  STOP               │
└──────┬──────────────┘
       │
       ↓
┌─────────────────────┐
│ Stop sensors        │
│ Keep data in memory │
│ Graph stays visible │
└──────┬──────────────┘
       │
       ↓
┌─────────────────────┐
│  Press              │
│  EXPORT             │
└──────┬──────────────┘
       │
       ↓
┌─────────────────────┐
│ Generate CSV        │
│ Save to file        │
│ Show path to user   │
└─────────────────────┘
```

## CSV Format

```
timestamp,alg1_angle,alg2_angle
1702819200000,0.0,0.0          ← Start
1702819200100,2.1,2.3
1702819200200,4.5,4.9
1702819200300,7.2,7.8
...
1702819205000,45.2,46.8        ← Peak
...
1702819210000,0.5,0.3          ← End
```

## Architecture Layers

```
┌─────────────────────────────────────────┐
│            UI LAYER                      │
│  (Views & Widgets)                       │
│                                          │
│  - HomeScreen: Controls & Status         │
│  - MeasurementChart: Graph Display       │
└────────────┬────────────────────────────┘
             │
             ↓ (observes)
┌─────────────────────────────────────────┐
│         VIEWMODEL LAYER                  │
│  (State Management)                      │
│                                          │
│  - MeasurementViewModel                  │
│    * isRecording state                   │
│    * measurements list                   │
│    * coordinate services                 │
└────────────┬────────────────────────────┘
             │
             ↓ (uses)
┌─────────────────────────────────────────┐
│          SERVICE LAYER                   │
│  (Business Logic)                        │
│                                          │
│  - SensorService: Read hardware          │
│  - AlgorithmService: Compute angles      │
│  - ExportService: Write CSV              │
└────────────┬────────────────────────────┘
             │
             ↓ (creates)
┌─────────────────────────────────────────┐
│          MODEL LAYER                     │
│  (Data Structures)                       │
│                                          │
│  - SensorReading: Raw sensor data        │
│  - MeasurementData: Processed data       │
└─────────────────────────────────────────┘
```

## File Organization

```
lib/
├── main.dart                    ← App entry
│
├── models/                      ← Data structures
│   ├── measurement_data.dart
│   └── sensor_reading.dart
│
├── services/                    ← Business logic
│   ├── sensor_service.dart      ← Hardware access
│   ├── algorithm_service.dart   ← Angle computation
│   └── export_service.dart      ← File I/O
│
├── viewmodels/                  ← State management
│   └── measurement_viewmodel.dart
│
├── views/                       ← Screens
│   └── home_screen.dart
│
└── widgets/                     ← Reusable UI
    └── measurement_chart.dart
```

## State Machine

```
┌──────────┐
│  IDLE    │ ← Initial state
└────┬─────┘
     │
     │ Press START
     ↓
┌──────────┐
│RECORDING │ → Sensors active
└────┬─────┘   Algorithms running
     │          Data collecting
     │          UI updating
     │
     │ Press STOP
     ↓
┌──────────┐
│ STOPPED  │ → Data in memory
└────┬─────┘   Graph frozen
     │          Export available
     │
     │ Press EXPORT
     ↓
┌──────────┐
│ EXPORTED │ → CSV saved
└────┬─────┘   Path shown
     │
     │ Press START (new recording)
     ↓
   (back to RECORDING)
```

## Key Features Summary

✅ Real-time sensor reading (50-100 Hz)
✅ Dual algorithm processing
✅ Live graph visualization
✅ CSV export for analysis
✅ Clean MVVM architecture
✅ No external dependencies
✅ Full offline operation
✅ Material Design 3 UI

---

This visual guide helps understand:
- How data flows through the app
- How algorithms process sensor data
- How UI interacts with business logic
- How the recording process works
