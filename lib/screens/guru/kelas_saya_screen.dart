import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/models.dart';
import '../../services/guru_service.dart';
import '../../services/kelas_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'detail_kelas_screen.dart';

class KelasSayaScreen extends StatefulWidget {
  const KelasSayaScreen({super.key});

  @override
  State<KelasSayaScreen> createState() => _KelasSayaScreenState();
}

class _KelasSayaScreenState extends State<KelasSayaScreen> {
  bool _isLoading = false;
  List<Kelas> _apiKelasList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final futures = await Future.wait([
      KelasService.instance.getKelas(),
      if (AppData.instance.guruDashboardData == null)
        GuruService.instance.getDashboardData(),
    ]);
    if (!mounted) return;

    final res = futures[0] as ApiResponse<List<Kelas>>;

    if (res.success && res.data != null) {
      setState(() {
        _apiKelasList = res.data!;
        _isLoading = false;
      });
    } else {
      // Also refresh dashboard data for fallback
      await GuruService.instance.getDashboardData();
      if (!mounted) return;
      setState(() {
        _errorMessage = res.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait([_loadKelas(), GuruService.instance.getDashboardData()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelas Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          if (_isLoading && _apiKelasList.isEmpty) {
            return const Center(
              child: LoadingState(message: 'Memuat data kelas...'),
            );
          }

          final data = AppData.instance;
          final dashboardData = data.guruDashboardData;
          final fallbackKelasList = _apiKelasList.isNotEmpty
              ? _apiKelasList
              : (dashboardData?.kelas.map((k) {
                      return Kelas(
                        id: k.id,
                        kodeKelas: k.kodeKelas,
                        namaKelas: k.namaKelas,
                        sekolah:
                            dashboardData.profil.sekolah?.namaSekolah ?? '-',
                        guruPengampu: dashboardData.profil.namaGuru,
                        jumlahSiswa: 0,
                        daftarSiswa: const [],
                        sekolahId:
                            dashboardData.profil.sekolahId ??
                            dashboardData.profil.sekolah?.id,
                        guruId: dashboardData.profil.id,
                      );
                    }).toList() ??
                    data.kelasForCurrentGuru());

          if (fallbackKelasList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),
                  EmptyState(
                    icon: Icons.class_outlined,
                    title: 'Belum ada kelas',
                    message:
                        _errorMessage ??
                        'Anda belum ditugaskan mengampu kelas apapun. Hubungi Admin Sekolah untuk menambahkan kelas Anda.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: fallbackKelasList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final k = fallbackKelasList[index];

                return AppCard(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailKelasScreen(kelas: k),
                      ),
                    );
                    _loadKelas();
                  },
                  child: InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailKelasScreen(kelas: k),
                        ),
                      );
                      _loadKelas();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                k.namaKelas,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                k.kodeKelas,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (k.sekolah.isNotEmpty)
                          Text(
                            k.sekolah,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              k.jumlahSiswa > 0
                                  ? '${k.jumlahSiswa} siswa'
                                  : 'Lihat siswa',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Kelola',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
