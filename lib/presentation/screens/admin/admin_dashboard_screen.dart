// lib/presentation/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/station_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'admin_bikes_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_stations_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    final stationsAsync = ref.watch(stationsProvider);
    final allBikesAsync = ref.watch(allBikesProvider);
    final allBookingsAsync = ref.watch(allBookingsProvider);

    final totalBikes = allBikesAsync.value?.length ?? 0;

    final availableBikes =
        allBikesAsync.value?.where((b) => b.status == 'available').length ?? 0;

    final activeBookings =
        allBookingsAsync.value?.where((b) => b.status == 'active').length ?? 0;

    final totalStations = stationsAsync.value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        user?.name ?? '',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();

                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (_) => false,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Statistics grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _StatCard(
                    'Stations',
                    '$totalStations',
                    Icons.location_on,
                    AppColors.primary,
                  ),
                  _StatCard(
                    'Total Bikes',
                    '$totalBikes',
                    Icons.directions_bike,
                    AppColors.secondary,
                  ),
                  _StatCard(
                    'Available',
                    '$availableBikes',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                  _StatCard(
                    'Active Trips',
                    '$activeBookings',
                    Icons.timer_outlined,
                    AppColors.warning,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Management',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 14),

              _AdminMenuCard(
                icon: Icons.location_on,
                title: 'Manage Stations',
                subtitle: '$totalStations registered stations',
                color: AppColors.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminStationsScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _AdminMenuCard(
                icon: Icons.directions_bike,
                title: 'Manage Bikes',
                subtitle: '$totalBikes total bikes',
                color: AppColors.secondary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminBikesScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _AdminMenuCard(
                icon: Icons.receipt_long,
                title: 'All Trips',
                subtitle: '$activeBookings currently active',
                color: AppColors.warning,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminBookingsScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _AdminMenuCard(
                icon: Icons.people_outline,
                title: 'Users',
                subtitle: 'Coming Soon',
                color: Colors.purple,
                onTap: () => _showComingSoon(
                  context,
                  'User Management',
                ),
                comingSoon: true,
              ),

              const SizedBox(height: 12),

              _AdminMenuCard(
                icon: Icons.bar_chart,
                title: 'Reports & Analytics',
                subtitle: 'Coming Soon',
                color: Colors.teal,
                onTap: () => _showComingSoon(
                  context,
                  'Reports',
                ),
                comingSoon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(
    BuildContext context,
    String feature,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.rocket_launch,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '$feature — Coming Soon!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
    this.label,
    this.value,
    this.icon,
    this.color,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool comingSoon;

  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                  ),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
