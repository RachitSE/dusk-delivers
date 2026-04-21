import 'package:geolocator/geolocator.dart';

enum StoreBranch { bidholi, pondha, closed }

class StoreRoutingService {
  static const double kandoliDividerLat = 30.3908860680363;

  static StoreBranch getFulfillmentBranch(Position userLocation) {
    final now = DateTime.now();
    final hour = now.hour;

    // 1. 10 AM to 5 PM: Only Bidholi is open.
    // Even if they are at Uttaranchal Univ (South), Bidholi delivers.
    if (hour >= 10 && hour < 17) {
      return StoreBranch.bidholi;
    }

    // 2. 5 PM to 9 PM: Both stores are open. Geofencing is ACTIVE.
    if (hour >= 17 && hour < 21) {
      if (userLocation.latitude >= kandoliDividerLat) {
        return StoreBranch.bidholi; // North of Kandoli PS
      } else {
        return StoreBranch.pondha; // South of Kandoli PS (Pondha/Uttaranchal)
      }
    }

    // 3. 9 PM to 4 AM: Only Pondha is open (The late-night specialist).
    if (hour >= 21 || hour < 4) {
      return StoreBranch.pondha;
    }

    // 4. 4 AM to 10 AM: Nap time.
    return StoreBranch.closed;
  }
}