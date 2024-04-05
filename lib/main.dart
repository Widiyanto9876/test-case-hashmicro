import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_case_hasmicro/maps_screen.dart';

void main() {
  runApp(const PresenceApp());
}

class PresenceApp extends StatelessWidget {
  const PresenceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presence App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AttendancePage(),
    );
  }
}

class AttendancePage extends StatefulWidget {
  final LatLng? latLng;

  const AttendancePage({
    Key? key,
    this.latLng,
  }) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _checkInLocation(),
            const SizedBox(height: 20),
            _pinLocation(),
            const SizedBox(height: 20),
            Text(_status),
          ],
        ),
      ),
    );
  }

  Widget _checkInLocation() {
    return GestureDetector(
      onTap: () {
        _checkIn();
      },
      child: SizedBox(
        height: 40,
        width: 200,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'Check In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigationToMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );
  }

  Widget _pinLocation() {
    return GestureDetector(
      onTap: () async {
        _navigationToMapScreen();
      },
      child: SizedBox(
        height: 40,
        width: 200,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'Pin Location',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkIn() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.latLng?.latitude ?? -7.972699256047862,
        widget.latLng?.longitude ?? 110.6071543485855,
      );
      if (distanceInMeters <= 50) {
        setState(() {
          _status = 'Attendance recorded successfully.';
        });
      } else {
        setState(() {
          _status = 'You are too far from the location to record attendance.';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    }
  }
}
