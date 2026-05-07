# Bicycle Rental App

Hourly Bicycle Rental Android App built with Flutter and Supabase.

## Features
- User Authentication (Login/Register)
- Role-based Access (User/Admin)
- Station Management
- Bike Booking
- Booking History
- Admin Dashboard

## Tech Stack
- Flutter 3.x
- Dart 3.x
- Supabase (Auth + PostgreSQL)
- Riverpod (State Management)
- GoRouter (Navigation)

## Setup
1. Run `flutter pub get`
2. Update `lib/core/constants/supabase_constants.dart` with your credentials
3. Run `supabase_schema.sql` in Supabase SQL Editor
4. Run `flutter run`

## Database Schema
- users
- stations
- bikes
- bookings

## License
MIT
