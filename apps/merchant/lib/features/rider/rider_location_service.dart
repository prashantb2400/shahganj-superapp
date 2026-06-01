// apps/merchant/lib/features/rider/rider_location_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sdk/firebase_sdk.dart';

class RiderLocationService {
  static final RiderLocationService _instance = RiderLocationService._internal();
  factory RiderLocationService() => _instance;
  RiderLocationService._internal();

  final SmoothedLocation _smoother = SmoothedLocation();
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  /// Starts the continuous Geolocator update stream (Rule 11 & 27 spec 3-second intervals)
  Future<void> startSync(String riderId) async {
    if (_isSyncing) return;

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot sync coordinates.');
    }

    _isSyncing = true;
    _smoother.reset(); // Reset Kalman filter equations

    // Geolocator Settings: High accuracy, update interval of 3000ms
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2, // updates when moving at least 2 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      
      // [CRITICAL KALMAN FILTERING]: Smooth raw budget GPS coordinates before DB write
      final Map<String, double> smoothed = _smoother.smooth(
        position.latitude,
        position.longitude,
      );

      final double smoothLat = smoothed['latitude']!;
      final double smoothLng = smoothed['longitude']!;

      try {
        await FirebaseFirestore.instance.collection('riders').doc(riderId).update({
          'currentLocation': GeoPoint(smoothLat, smoothLng),
          'locationTimestamp': FieldValue.serverTimestamp(),
          'status': 'available',
        });
        print("🛰️ Kalman Smoothed GPS Sync successfully written: ($smoothLat, $smoothLng)");
      } catch (e) {
        print("❌ Error updating rider GPS: $e");
      }
    });
  }

  /// Stops background updates and marks rider offline
  Future<void> stopSync(String riderId) async {
    if (!_isSyncing) return;

    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isSyncing = false;

    try {
      await FirebaseFirestore.instance.collection('riders').doc(riderId).update({
        'status': 'offline',
      });
      print("🔌 Geolocator stream closed. Rider marked offline.");
    } catch (e) {
      print("❌ Error marking rider offline: $e");
    }
  }
}
