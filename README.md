# Bicycle Rental App

App ya Android ya kukodi baiskeli kwa saa. Inaruhusu watumiaji kuhifadhi baiskeli, kuichukua kutoka kwenye kituo, na kuirudisha wanapomaliza. Msimamizi anaweza kudhibiti baiskeli, vituo, na kuona taarifa za mikopo na watumiaji.

## Features

### Kwa Mteja (User):
- ✅ Ingia / Jisajili
- ✅ Tazama vituo vya baiskeli
- ✅ Kodi baiskeli kwa saa
- ✅ Tazama historia ya mikopo
- ✅ Hariri wasifu

### Kwa Msimamizi (Admin):
- ✅ Dashboard na muhtasari
- ✅ Dhibiti baiskeli (Ongeza/Hariri/Futa)
- ✅ Dhibiti vituo
- ✅ Tazama watumiaji wote
- ✅ Tazama mikopo yote

## Tech Stack

- **Flutter** - UI framework
- **Supabase** - Backend (Auth, Database, Realtime)
- **Riverpod** - State management
- **GoRouter** - Navigation
- **Freezed** - Immutable models

## Setup Instructions

### 1. Create Flutter Project
```bash
flutter create bicycle_rental
cd bicycle_rental
```

### 2. Copy Files
Nakili mafaili yote kutoka kwenye `lib/` folder.

### 3. Update Supabase Credentials
Fungua `lib/core/constants/supabase_constants.dart` na weka URL na Anon Key zako:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 4. Run Supabase Schema
Nakili maudhui ya `supabase_schema.sql` uende kwenye Supabase SQL Editor uka-run.

### 5. Install Dependencies
```bash
flutter pub get
```

### 6. Generate Code (Freezed)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 7. Run App
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App constants
│   │   └── supabase_constants.dart    # Supabase config
│   └── theme/
│       └── app_theme.dart             # App theme
├── data/
│   ├── models/
│   │   ├── user_model.dart            # User model
│   │   ├── station_model.dart         # Station model
│   │   ├── bike_model.dart            # Bike model
│   │   └── booking_model.dart         # Booking model
│   └── repositories/
│       └── auth_repository.dart       # Auth repository
├── providers/
│   └── auth_provider.dart             # Auth state management
├── router/
│   └── app_router.dart                # GoRouter configuration
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart          # Login UI
│   │   └── register_screen.dart       # Register UI
│   ├── home/
│   │   └── home_screen.dart           # User home
│   └── admin/
│       └── admin_dashboard.dart       # Admin dashboard
└── widgets/                           # Shared widgets
```

## Database Schema

### Tables:
- **users** - Watumiaji (id, name, email, phone, role)
- **stations** - Vituo (id, name, location, total_slots)
- **bikes** - Baiskeli (id, station_id, model, status)
- **bookings** - Mikopo (id, user_id, bike_id, station_id, start_time, end_time, hours, total_cost, status)

## License

MIT License
