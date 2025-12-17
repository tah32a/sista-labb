# Quick Start Guide

## Running the App (5 Steps)

### Step 1: Verify Flutter Installation
```bash
cd /Users/tah42a/lab-sist
flutter doctor
```

### Step 2: Get Dependencies
```bash
flutter pub get
```

### Step 3: Connect Your Device

**For iOS:**
- Connect iPhone/iPad via USB
- Trust the computer on device
- Check connection: `flutter devices`

**For Android:**
- Enable Developer Mode on device
- Enable USB Debugging
- Connect via USB
- Check connection: `flutter devices`

### Step 4: Run the App
```bash
flutter run
```

Or specify a device:
```bash
flutter run -d <device-id>
```

### Step 5: Test the App

1. Press **Start** button
2. Move your arm from 0° to 90° and back to 0°
3. Press **Stop** button
4. View the graph showing both algorithms
5. Press **Export** to save CSV file

## Expected Output

- **Live Graph**: Two lines (blue = Algorithm 1, red = Algorithm 2)
- **Samples**: 500-1000 for 10s recording, 50-100 for 1s recording
- **CSV File**: Located at `/storage/.../arm_elevation_<timestamp>.csv`

## Troubleshooting

### "No devices found"
```bash
flutter devices
# Connect device and enable developer mode
```

### "Build failed"
```bash
flutter clean
flutter pub get
flutter run
```

### "Sensor not working"
- Ensure device has accelerometer and gyroscope
- Physical device required (simulator won't work)
- Restart the app

## File Locations

- **Source Code**: `/Users/tah42a/lab-sist/lib/`
- **Documentation**: See README.md, ARCHITECTURE.md, TESTING_GUIDE.md
- **CSV Exports**: Device storage (path shown after export)

## Important Notes

- **Physical Device Required**: Sensors don't work in simulators
- **Permissions**: App requests storage permission for CSV export
- **Orientation**: Hold phone along arm with Y-axis pointing toward hand
- **Movement**: Smooth movements work best for testing

## Success Indicators

✅ App launches without errors
✅ Buttons are responsive
✅ Graph displays during recording
✅ Stop button freezes the graph
✅ Export creates CSV file
✅ CSV has correct format: `timestamp,alg1_angle,alg2_angle`

---

**Ready to submit!** All code is complete and functional.
