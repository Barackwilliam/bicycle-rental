// lib/core/constants/app_constants.dart

class AppConstants {
  static const String appName = 'BikeRent';

  // Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  // Bike statuses
  static const String bikeAvailable = 'available';
  static const String bikeRented = 'rented';
  static const String bikeMaintenance = 'maintenance';

  // Booking statuses
  static const String bookingActive = 'active';
  static const String bookingCompleted = 'completed';
  static const String bookingCancelled = 'cancelled';

  // Pricing
  static const double pricePerHour = 2000.0; // TZS per hour
  static const String currency = 'TZS';
}
