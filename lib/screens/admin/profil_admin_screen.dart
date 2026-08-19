import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../auth/login_screen.dart';

class ProfilAdminScreen extends StatelessWidget {
  const ProfilAdminScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keluar Akun',
      message: 'Anda yakin ingin keluar dari akun administrator?',
      confirmLabel: 'Keluar',
    );
    if (!confirmed) return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    await AuthService.instance.logout();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Administrator')),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final data = AppData.instance;
          final user = data.currentUser;

          final nama = user?.name ?? user?.email.split('@').first ?? 'Administrator';
          final email = user?.email ?? 'admin@sekolah.com';
          final role = user?.role.toUpperCase() ?? 'ADMINISTRATOR';
          final id = user?.id ?? '-';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Detail Info Card
              AppCard(
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email Akun',
                      value: email,
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.vpn_key_outlined,
                      label: 'Hak Akses',
                      value: 'Super Admin (Full Access)',
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.fingerprint_outlined,
                      label: 'User ID',
                      value: id.length > 16 ? '${id.substring(0, 16)}...' : id,
                    ),
                    const Divider(),
                    const InfoRow(
                      icon: Icons.security_outlined,
                      label: 'Status Sistem',
                      value: 'Aktif / Terautentikasi',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Version & About
              AppCard(
                child: Column(
                  children: [
                    const InfoRow(
                      icon: Icons.info_outline,
                      label: 'Aplikasi',
                      value: 'Akademik v1.0.0',
                    ),
                    const Divider(),
                    const InfoRow(
                      icon: Icons.cloud_outlined,
                      label: 'Server API',
                      value: 'Production Neon Cloud',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                label: 'Keluar dari Akun',
                variant: AppButtonVariant.danger,
                icon: Icons.logout,
                onPressed: () => _handleLogout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
