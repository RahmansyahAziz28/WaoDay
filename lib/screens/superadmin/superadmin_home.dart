import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/sekolah.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../auth/login_screen.dart';
import 'manajemen_admin_sekolah_screen.dart';
import 'manajemen_sekolah_screen.dart';

/// Screen shell for SuperAdmin role.
/// Provides tab navigation between Manajemen Sekolah and Manajemen Admin per Sekolah,
/// along with top identity banner and logout handling.
class SuperAdminHome extends StatefulWidget {
  const SuperAdminHome({super.key});

  static const routeName = '/superadmin';

  @override
  State<SuperAdminHome> createState() => _SuperAdminHomeState();
}

class _SuperAdminHomeState extends State<SuperAdminHome> {
  int _currentIndex = 0;
  String? _filterSekolahIdForAdmin;

  Future<void> _handleLogout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keluar dari Akun?',
      message: 'Apakah Anda yakin ingin keluar dari sesi SuperAdmin ini?',
      confirmLabel: 'Keluar',
      cancelLabel: 'Batal',
      isDangerous: true,
    );

    if (!confirmed || !mounted) return;

    await AuthService.instance.logout();
    if (!mounted) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }

  void _onSelectSekolahForAdmin(Sekolah sekolah) {
    setState(() {
      _filterSekolahIdForAdmin = sekolah.id;
      _currentIndex = 1; // Switch to Admin tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AppData.instance.currentUser;
    final userName =
        currentUser?.name ??
        currentUser?.email.split('@').first ??
        'Super Admin';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _currentIndex == 0
                      ? 'Kelola Data Sekolah'
                      : 'Kelola Admin Sekolah',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Keluar',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ManajemenSekolahScreen(
            onSelectSekolahForAdmin: _onSelectSekolahForAdmin,
          ),
          ManajemenAdminSekolahScreen(
            initialSekolahId: _filterSekolahIdForAdmin,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
            if (idx == 0) {
              _filterSekolahIdForAdmin = null;
            }
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded, color: AppColors.primary),
            label: 'Sekolah',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.secondary,
            ),
            label: 'Admin Sekolah',
          ),
        ],
      ),
    );
  }
}
