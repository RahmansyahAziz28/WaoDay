import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../admin/admin_home.dart';
import '../guru/guru_home.dart';
import '../superadmin/superadmin_home.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final start = DateTime.now();
    final session = await AuthService.instance.restoreSession();
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    if (elapsed < 1200) {
      await Future.delayed(Duration(milliseconds: 1200 - elapsed));
    }

    if (!mounted) return;

    if (session != null) {
      final roleStr = session.user.role.toLowerCase();
      if (roleStr == 'superadmin' ||
          roleStr == 'super_admin' ||
          AppData.instance.currentRole == UserRole.superadmin) {
        Navigator.of(context).pushReplacementNamed(SuperAdminHome.routeName);
      } else if (roleStr == 'admin' ||
          roleStr == 'administrator' ||
          AppData.instance.currentRole == UserRole.admin) {
        Navigator.of(context).pushReplacementNamed(AdminHome.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(GuruHome.routeName);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.school_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Akademik',
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manajemen Sekolah SMA/SMK',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.6),
            ),
          ],
        ),
      ),
    );
  }
}
