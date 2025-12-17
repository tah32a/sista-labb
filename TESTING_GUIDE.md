# Testing Guide for Arm Elevation Tracker

## Prerequisites

- Flutter SDK installed (>= 3.0.0)
- Physical device with accelerometer and gyroscope (iOS or Android)
- USB cable for device connection
- Device developer mode enabled

## Setup Instructions

### 1. Enable Developer Mode

**Android:**
- Go to Settings > About Phone
- Tap "Build Number" 7 times to enable Developer Options
- Go to Settings > Developer Options
- Enable "USB Debugging"

**iOS:**
- Connect device to Mac
- Open Xcode
- Go to Window > Devices and Simulators
- Select your device and click "Use for Development"

### 2. Connect Device

```bash
# List connected devices
flutter devices

# You should see your device listed
```

### 3. Install Dependencies

```bash
cd /Users/tah42a/lab-sist
flutter pub get
```

### 4. Run the Application

```bash
# Run on connected device
flutter run

# Or specify device
flutter run -d <device-id>
```

## Testing Procedure

### Test 1: Basic Functionality

1. **Launch App**: App should open to home screen with three buttons
2. **Initial State**: 
   - Status should show "Stopped"
   - Start button enabled (green)
   - Stop button disabled (gray)
   - Export button disabled (gray)
   - "No data yet" message displayed

### Test 2: Slow Movement Recording (~10 seconds)

1. **Setup**:
   - Stand upright
   - Hold phone firmly against your arm (Y-axis along arm length)
   - Arm should start in vertical position (0°)

2. **Recording**:
   - Press "Start" button
   - Status changes to "Recording..."
   - Slowly raise arm from 0° to 90° (5 seconds)
   - Slowly lower arm from 90° to 0° (5 seconds)
   - Press "Stop" button

3. **Verification**:
   - Graph should display two lines (blue and red)
   - Lines should show smooth progression: 0° → 90° → 0°
   - Both algorithms should track similarly (may diverge slightly)
   - Sample count should be ~500-1000 (depending on sensor rate)
   - Duration should show ~10s

### Test 3: Fast Movement Recording (~1 second)

1. **Setup**: Same as Test 2

2. **Recording**:
   - Press "Start" button
   - Quickly raise arm from 0° to 90° (0.5 seconds)
   - Quickly lower arm from 90° to 0° (0.5 seconds)
   - Press "Stop" button

3. **Verification**:
   - Graph should show sharp peaks
   - Algorithm 1 (blue) may show more smoothing due to EWMA filter
   - Algorithm 2 (red) may track faster movements more accurately
   - Sample count should be ~50-100
   - Duration should show ~1s

### Test 4: Export Functionality

1. **After Recording**:
   - Stop button should be disabled
   - Export button should be enabled (blue)
   - Press "Export" button

2. **Verification**:
   - Toast message should appear with file path
   - File path should be: `/data/.../arm_elevation_<timestamp>.csv`
   - File should exist at specified location

3. **CSV Verification**:
   - Transfer file to computer via USB or file manager
   - Open in Excel or text editor
   - Should have header: `timestamp,alg1_angle,alg2_angle`
   - Should have one row per sample
   - Timestamps should be in milliseconds since epoch
   - Angles should be between 0 and 90

### Test 5: Multiple Measurements

1. **Sequential Tests**:
   - Perform Test 2 (slow movement)
   - Press "Start" again - previous data should clear
   - Perform Test 3 (fast movement)
   - Export data
   - Verify only fast movement data is in CSV

2. **Verification**:
   - Each new recording should clear previous data
   - Export should always contain latest recording only
   - Graph should update in real-time during recording

## Expected Behavior

### Algorithm 1 (EWMA Filter)
- **Blue line**
- Smoother trajectory
- Slower response to rapid changes
- Less noise
- Good for steady movements

### Algorithm 2 (Sensor Fusion)
- **Red line**
- More responsive to quick movements
- May show slight drift over long periods
- Better tracking of rapid accelerations
- Complementary filter reduces gyro drift

### Normal Differences Between Algorithms
- Algorithm 1 lags behind Algorithm 2 during fast movements
- Algorithm 2 may overshoot slightly during rapid direction changes
- Both should converge to similar values during steady positions
- Difference typically within 5-10° during movement

## Troubleshooting

### App Won't Build
```bash
flutter clean
flutter pub get
flutter run
```

### Sensors Not Working
- Ensure device has accelerometer and gyroscope
- Check device sensors: Settings > About Phone > Hardware/Sensors
- Try restarting the app

### Export Fails
- Check storage permissions
- On Android 11+, may need to manually grant storage permission
- Go to Settings > Apps > Arm Elevation Tracker > Permissions

### Graph Not Updating
- Ensure device is not in power-saving mode
- Check that sensor services are running
- Restart the app

## Performance Expectations

- **Sensor Rate**: 50-100 Hz (typical for mobile devices)
- **UI Update Rate**: Real-time (every sample)
- **Memory Usage**: < 50MB for 30-second recording
- **CPU Usage**: Moderate during recording
- **Battery**: Minimal impact for short recordings

## Data Analysis in Excel

1. **Open CSV File** in Excel
2. **Create Graph**:
   - Select all data
   - Insert > Scatter Chart > Scatter with Smooth Lines
   - X-axis: timestamp (or calculate time offset)
   - Y-axis: alg1_angle and alg2_angle as separate series

3. **Analysis**:
   - Compare algorithm performance
   - Identify noise levels
   - Measure peak angles
   - Calculate movement duration

## Contact

For issues or questions, refer to the README.md file in the project root.
