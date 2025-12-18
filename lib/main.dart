import 'package:flutter/material.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const ArmElevationApp());
}

class ArmElevationApp extends StatelessWidget {
  const ArmElevationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arm Elevation Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
