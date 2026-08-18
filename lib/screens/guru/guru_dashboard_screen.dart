import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/models.dart';
import '../../services/guru_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'daftar_siswa_screen.dart';
import 'detail_kelas_screen.dart';

class GuruDashboardScreen extends StatefulWidget {
  const GuruDashboardScreen({super.key});

  @override
  State<GuruDashboardScreen> createState() => _GuruDashboardScreenState();
}

class _GuruDashboardScreenState extends State<GuruDashboardScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await GuruService.instance.getDashboardData();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (!response.success && AppData.instance.guruDashboardData == null) {
        _errorMessage = response.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _isLoading ? null : _fetchDashboard,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final data = AppData.instance;
          final dashboardData = data.guruDashboardData;
          final guru = data.currentGuru;

          if (_isLoading && dashboardData == null && guru == null) {
            return const LoadingState(message: 'Memuat data dashboard...');
          }

          if (_errorMessage != null && dashboardData == null && guru == null) {
            return RefreshIndicator(
              onRefresh: _fetchDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 60),
                      const Icon(Icons.cloud_off_outlined, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Coba Lagi',
                        onPressed: _fetchDashboard,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final namaGuru = dashboardData?.profil.namaGuru ?? guru?.nama ?? 'Guru';
          final nimGuru = dashboardData?.profil.nim ?? guru?.nim ?? '-';
          final namaSekolah = dashboardData?.profil.sekolah?.namaSekolah ?? guru?.sekolah ?? '-';
          final kodeKelasUtama = (dashboardData != null && dashboardData.kelas.isNotEmpty)
              ? dashboardData.kelas.first.kodeKelas
              : (guru?.kodeKelas ?? '-');

          final totalKelas = dashboardData?.statistik.totalKelas ?? data.kelasForCurrentGuru().length;
          final totalSiswa = dashboardData?.statistik.totalSiswa ??
              data.kelasForCurrentGuru().fold<int>(0, (sum, k) => sum + k.jumlahSiswa);

          final apiKelasList = dashboardData?.kelas ?? [];
          final fallbackKelasList = data.kelasForCurrentGuru();

          return RefreshIndicator(
            onRefresh: _fetchDashboard,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      AppAvatar(name: namaGuru, size: 56, backgroundColor: AppColors.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaGuru,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              namaSekolah,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'NIM: $nimGuru',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                                if (kodeKelasUtama != '-')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Kode: $kodeKelasUtama',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.class_outlined,
                        label: 'Kelas Diampu',
                        value: '$totalKelas',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.groups_outlined,
                        label: 'Total Siswa',
                        value: '$totalSiswa',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kelas Saya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DaftarSiswaScreen()),
                      ),
                      child: const Text('Lihat Semua Siswa'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (apiKelasList.isEmpty && fallbackKelasList.isEmpty)
                  const EmptyState(
                    icon: Icons.class_outlined,
                    title: 'Belum ada kelas',
                    message: 'Anda belum ditugaskan mengampu kelas.',
                  )
                else if (apiKelasList.isNotEmpty)
                  ...apiKelasList.map(
                    (k) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () {
                          final mappedKelas = Kelas(
                            id: k.id,
                            kodeKelas: k.kodeKelas,
                            namaKelas: k.namaKelas,
                            sekolah: namaSekolah,
                            guruPengampu: namaGuru,
                            jumlahSiswa: 0,
                            daftarSiswa: const [],
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetailKelasScreen(kelas: mappedKelas),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.class_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    k.namaKelas,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kode: ${k.kodeKelas}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...fallbackKelasList.map(
                    (k) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DetailKelasScreen(kelas: k)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.class_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    k.namaKelas,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${k.kodeKelas} · ${k.jumlahSiswa} siswa',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
