// packages/firebase_sdk/lib/src/services/geolocation_smoother.dart

class GeolocationSmoother {
  double _q = 0.00001;  // Process noise
  double _r = 0.0001;   // Measurement noise
  double? _x;           // State estimate
  double _p = 1.0;      // Error covariance

  GeolocationSmoother({double? q, double? r}) {
    if (q != null) _q = q;
    if (r != null) _r = r;
  }

  double update(double measurement) {
    _p = _p + _q;
    final k = _p / (_p + _r);  // Kalman gain
    _x = (_x ?? measurement) + k * (measurement - (_x ?? measurement));
    _p = (1.0 - k) * _p;
    return _x!;
  }

  void reset() {
    _x = null;
    _p = 1.0;
  }
}

class SmoothedLocation {
  final GeolocationSmoother _latSmoother = GeolocationSmoother();
  final GeolocationSmoother _lngSmoother = GeolocationSmoother();

  // Returns smoothed latitude and longitude values
  Map<String, double> smooth(double lat, double lng) {
    return {
      'latitude': _latSmoother.update(lat),
      'longitude': _lngSmoother.update(lng),
    };
  }

  void reset() {
    _latSmoother.reset();
    _lngSmoother.reset();
  }
}
