import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationHelper {
  /// Konum servisinin açık olup olmadığını kontrol eder
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Konum iznini kontrol eder ve gerekirse ister
  static Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Mevcut konumu alır
  static Future<LatLng?> getCurrentLocation() async {
    try {
      // Servis açık mı kontrol et
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // İzin kontrolü
      LocationPermission permission = await checkAndRequestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Konumu al
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  /// İzin durumunu string olarak döndürür
  static String getPermissionStatusMessage(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Konum izni reddedildi. Lütfen izin verin.';
      case LocationPermission.deniedForever:
        return 'Konum izni kalıcı olarak reddedildi. Ayarlardan izin vermeniz gerekiyor.';
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return 'Konum izni verildi.';
      default:
        return 'Konum izni durumu bilinmiyor.';
    }
  }
}

