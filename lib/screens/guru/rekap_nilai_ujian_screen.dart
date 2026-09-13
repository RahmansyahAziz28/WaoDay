import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../../services/game_token_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class RekapNilaiUjianScreen extends StatefulWidget {
  final String tokenId;
  final String kodeToken;

  const RekapNilaiUjianScreen({
    super.key,
    required this.tokenId,
    required this.kodeToken,
  });

  @override
  State<RekapNilaiUjianScreen> createState() => _RekapNilaiUjianScreenState();
}

class _RekapNilaiUjianScreenState extends State<RekapNilaiUjianScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  RekapNilaiData? _data;

  @override
  void initState() {
    super.initState();
    _loadRekap();
  }

  Future<void> _loadRekap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await GameTokenService.instance.getRekapNilai(
        widget.tokenId,
        kkm: 70,
      );

      if (!mounted) return;

      if (res.success && res.data != null) {
        setState(() {
          _data = res.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = res.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat rekap nilai: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFEAB308); // Gold
      case 2:
        return const Color(0xFF94A3B8); // Silver
      case 3:
        return const Color(0xFFD97706); // Bronze
      default:
        return AppColors.textSecondary.withValues(alpha: 0.7);
    }
  }

  Color _getRankBgColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFEF9C3); // Soft Gold
      case 2:
        return const Color(0xFFF1F5F9); // Soft Silver
      case 3:
        return const Color(0xFFFFEDD5); // Soft Bronze
      default:
        return AppColors.background;
    }
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    Widget? trailingWidget,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (trailingWidget != null)
            trailingWidget
          else
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rekap Nilai - ${widget.kodeToken}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Salin Kode Token',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.kodeToken));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kode token ${widget.kodeToken} disalin!'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _loadRekap,
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _loadRekap, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _data == null) {
      return const Center(
        child: LoadingState(message: 'Memuat rekap nilai siswa...'),
      );
    }

    if (_errorMessage != null && _data == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          EmptyState(
            icon: Icons.error_outline,
            title: 'Gagal Memuat Rekap Nilai',
            message: _errorMessage!,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: AppButton(label: 'Coba Lagi', onPressed: _loadRekap),
          ),
        ],
      );
    }

    final data = _data!;
    final paket = data.paket;
    final rekap = data.rekap;
    final nilaiList = data.nilai;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ── Card Ringkasan Ujian ─────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paket.namaSesi,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Token: ${paket.kodeToken}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${paket.jumlahSoal} Soal',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (paket.semester != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Semester ${paket.semester}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'KKM: ${rekap.kkm}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${rekap.totalPemain} Siswa Selesai',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // ── Grid 4 Kartu Statistik ──────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Rata-rata Nilai',
                value: rekap.rerataNilai.toStringAsFixed(1),
                icon: Icons.analytics_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                label: 'Nilai Tertinggi',
                value: rekap.nilaiTertinggi.toStringAsFixed(0),
                icon: Icons.emoji_events_outlined,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Nilai Terendah',
                value: rekap.nilaiTerendah.toStringAsFixed(0),
                icon: Icons.trending_down_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                label: 'Ketuntasan (KKM ${rekap.kkm})',
                value: '',
                icon: Icons.verified_outlined,
                color: AppColors.secondary,
                trailingWidget: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${rekap.tuntas} Tuntas',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${rekap.belumTuntas} Remedi',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Header Daftar Siswa / Leaderboard ───────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Leaderboard & Hasil Siswa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            Text(
              '${nilaiList.length} Siswa',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── List Item Siswa / Nilai ─────────────────────────────────────────
        if (nilaiList.isEmpty)
          const EmptyState(
            icon: Icons.people_outline,
            title: 'Belum Ada Siswa yang Mengerjakan',
            message:
                'Siswa yang memasukkan token ini dan menyelesaikan game akan otomatis terdata di sini.',
          )
        else
          ...nilaiList.map((item) {
            final isTop3 = item.peringkat <= 3;
            final rankColor = _getRankColor(item.peringkat);
            final rankBg = _getRankBgColor(item.peringkat);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Lingkaran Peringkat (#1, #2, #3, dst.)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: rankBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isTop3 ? rankColor : AppColors.border,
                          width: isTop3 ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '#${item.peringkat}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: rankColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Nama & Rincian Jawaban Siswa
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.namaPemain,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (item.nis.isNotEmpty) ...[
                                Text(
                                  'NIS: ${item.nis}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const Text(
                                  ' • ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              Text(
                                'Benar: ${item.totalBenar}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Salah: ${item.totalSalah}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Badge Skor & Status Ketuntasan
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.nilai.toStringAsFixed(
                            item.nilai.truncateToDouble() == item.nilai ? 0 : 1,
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: item.tuntas
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.tuntas
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.tuntas ? 'Tuntas' : 'Remedial',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: item.tuntas
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
