import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../services/auth_service.dart';
import '../../services/guru_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../auth/login_screen.dart';

class ProfilGuruScreen extends StatelessWidget {
  const ProfilGuruScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keluar Akun',
      message: 'Anda yakin ingin keluar dari akun ini?',
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

  Future<void> _handleRefresh() async {
    await GuruService.instance.getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Guru')),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final data = AppData.instance;
          final dashboard = data.guruDashboardData;
          final guru = data.currentGuru;
          final user = data.currentUser;

          final nama = dashboard?.profil.namaGuru ?? guru?.nama ?? user?.email.split('@').first ?? 'Guru';
          final nim = dashboard?.profil.nim ?? guru?.nim ?? '-';
          final sekolah = dashboard?.profil.sekolah?.namaSekolah ?? guru?.sekolah ?? '-';
          final email = user?.email ?? '-';
          final kodeKelas = (dashboard != null && dashboard.kelas.isNotEmpty)
              ? dashboard.kelas.first.kodeKelas
              : (guru?.kodeKelas ?? '-');

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      AppAvatar(name: nama, size: 84, backgroundColor: AppColors.primary),
                      const SizedBox(height: 14),
                      Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Guru',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppCard(
                  child: Column(
                    children: [
                      InfoRow(icon: Icons.badge_outlined, label: 'NIM', value: nim),
                      const Divider(),
                      InfoRow(icon: Icons.email_outlined, label: 'Email', value: email),
                      const Divider(),
                      InfoRow(icon: Icons.apartment_outlined, label: 'Sekolah', value: sekolah),
                      if (kodeKelas != '-') ...[
                        const Divider(),
                        InfoRow(icon: Icons.qr_code_outlined, label: 'Kode Kelas', value: kodeKelas),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Keluar',
                  variant: AppButtonVariant.danger,
                  icon: Icons.logout,
                  onPressed: () => _handleLogout(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
