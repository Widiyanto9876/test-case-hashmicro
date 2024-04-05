import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_case_hasmicro/main.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final Completer<GoogleMapController> _controller = Completer();
  late LatLng _pickedLocation;
  final List<Marker> _markers = [];

  LatLng? _currentPosition;

  Future<void> _getCurrentLocation() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _currentPosition ??
              const LatLng(
                -7.972445387858521,
                110.6072283787198,
              ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    } else {
      showDialogPermission();
    }
  }

  void showDialogPermission() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Location permission required'),
        content: const Text(
            'Please grant location permission in app settings to proceed.'),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _getCurrentLocation();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getCurrentLocation();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Pin'),
      ),
      body: _currentPosition == null
          ? Container()
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition ??
                    const LatLng(
                      -7.972445387858521,
                      110.6072283787198,
                    ),
                zoom: 15,
              ),
              markers: Set<Marker>.of(_markers),
              onTap: (latLong) => _addMarker(latLong),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_markers.length > 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => AttendancePage(
                        latLng: _pickedLocation,
                      )),
              (route) => false,
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _addMarker(LatLng position) {
    setState(() {
      if (_markers.length > 1) {
        _markers.removeAt(1);
      }
      _pickedLocation = position;
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'Picked Location',
            snippet:
                'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
          ),
        ),
      );
    });
  }
}
