import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<GeoPoint?> getCurrentLocation() async {
    try {
      // Check if location services are enabled at the device level
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // Request if not yet granted
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Give up if still denied or permanently denied
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Location timeout'),
      );

      return GeoPoint(position.latitude, position.longitude);
    } catch (_) {
      // If anything goes wrong, just return null — location is optional
      return null;
    }
  }
}
