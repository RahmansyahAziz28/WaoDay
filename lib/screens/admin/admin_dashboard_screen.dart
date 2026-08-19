import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/guru.dart';
import '../../models/sekolah.dart';
import '../../services/admin_service.dart';
import '../../services/kelas_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    this.onNavigateToSekolah,
    this.onNavigateToGuru,
  });

  final VoidCallback? onNavigateToSekolah;
  final VoidCallback? onNavigateToGuru;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = false;
  List<Sekolah> _sekolahList = [];
  List<Guru> _guruList = [];
  int _totalKelas = 0;
  int _totalSiswa = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = await Future.wait([
        AdminService.instance.getSekolahList(),
        AdminService.instance.getGuruList(page: 1, limit: 10),
        KelasService.instance.getKelas(),
      ]);

      if (!mounted) return;

      final sekolahRes = futures[0] as dynamic;
      final guruRes = futures[1] as dynamic;
      final kelasRes = futures[2] as dynamic;

      setState(() {
        _isLoading = false;
        if (sekolahRes.success && sekolahRes.data != null) {
          _sekolahList = sekolahRes.data as List<Sekolah>;
        }
        if (guruRes.success && guruRes.data != null) {
          _guruList = guruRes.data as List<Guru>;
        }
        if (kelasRes.success && kelasRes.data != null) {
          final kList = kelasRes.data as List;
          _totalKelas = kList.length;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat beberapa data: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppData.instance.currentUser;
    final userName = user?.name ?? user?.email.split('@').first ?? 'Administrator';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _isLoading ? null : _fetchDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hai, $userName 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Administrator Sistem Akademik',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Sistem Terhubung ke Server',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Metric Statistics Grid
            const Text(
              'Ringkasan Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _buildStatCard(
                  title: 'Total Sekolah',
                  value: '${_sekolahList.length}',
                  icon: Icons.apartment_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: widget.onNavigateToSekolah,
                ),
                _buildStatCard(
                  title: 'Total Guru',
                  value: '${_guruList.length}',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF0F766E),
                  onTap: widget.onNavigateToGuru,
                ),
                _buildStatCard(
                  title: 'Total Kelas',
                  value: '$_totalKelas',
                  icon: Icons.class_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
                _buildStatCard(
                  title: 'Server API',
                  value: 'Online',
                  icon: Icons.cloud_done_rounded,
                  color: const Color(0xFF16A34A),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    onTap: widget.onNavigateToSekolah,
                    child: const Row(
                      children: [
                        Icon(Icons.add_business_rounded, color: AppColors.primary, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Kelola Sekolah',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    onTap: widget.onNavigateToGuru,
                    child: const Row(
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, color: AppColors.secondary, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Kelola Guru',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preview List Sekolah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sekolah Terdaftar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                if (widget.onNavigateToSekolah != null)
                  TextButton(
                    onPressed: widget.onNavigateToSekolah,
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading && _sekolahList.isEmpty)
              const Center(child: LoadingState(message: 'Memuat data...'))
            else if (_sekolahList.isEmpty)
              const EmptyState(
                icon: Icons.apartment_outlined,
                title: 'Belum ada sekolah',
                message: 'Data sekolah akan tampil di sini setelah ditambahkan.',
              )
            else
              ..._sekolahList.take(3).map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.school, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.namaSekolah,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              if (s.alamat != null && s.alamat!.isNotEmpty)
                                Text(
                                  s.alamat!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
