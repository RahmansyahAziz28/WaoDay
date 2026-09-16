import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';

import '../../data/dummy_data.dart';
import '../../models/models.dart';
import '../../services/game_token_service.dart';
import '../../services/kelas_service.dart';
import '../../services/nilai_sub_bab_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'buat_token_ujian_screen.dart';
import 'rekap_nilai_ujian_screen.dart';

class DetailKelasScreen extends StatefulWidget {
  const DetailKelasScreen({super.key, required this.kelas});

  final Kelas kelas;

  @override
  State<DetailKelasScreen> createState() => _DetailKelasScreenState();
}

class _DetailKelasScreenState extends State<DetailKelasScreen> {
  late Kelas _currentKelas;
  List<Siswa> _siswaList = [];
  List<GameTokenItem> _tokenList = [];
  String? _downloadingTokenId;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedTabIndex = 0; // 0: Siswa, 1: Token Ujian

  @override
  void initState() {
    super.initState();
    _currentKelas = widget.kelas;
    _siswaList = List.from(widget.kelas.daftarSiswa);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = await Future.wait([
        KelasService.instance.getKelasDetail(_currentKelas.id),
        KelasService.instance.getSiswaInKelas(_currentKelas.id),
        GameTokenService.instance.getTokensByKelas(_currentKelas.id),
      ]);

      if (!mounted) return;

      final detailRes = futures[0] as ApiResponse<Kelas>;
      final siswaRes = futures[1] as ApiResponse<List<Siswa>>;
      final tokenRes = futures[2] as ApiResponse<List<GameTokenItem>>;

      setState(() {
        _isLoading = false;
        if (detailRes.success && detailRes.data != null) {
          _currentKelas = detailRes.data!;
        }
        if (siswaRes.success && siswaRes.data != null) {
          _siswaList = siswaRes.data!;
        }
        if (tokenRes.success && tokenRes.data != null) {
          _tokenList = tokenRes.data!;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
      });
    }
  }

  Future<void> _openBuatToken() async {
    final res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BuatTokenUjianScreen(kelas: _currentKelas),
      ),
    );
    if (res == true) {
      setState(() => _selectedTabIndex = 1);
      _loadData();
    }
  }

  Widget _buildTokenInfoChip({
    required IconData icon,
    required String label,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isHighlight
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isHighlight ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showSiswaOptions(Siswa siswa) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    AppAvatar(name: siswa.nama, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            siswa.nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            'NIS ${siswa.nis}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Edit Siswa'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _showSiswaFormModal(siswa: siswa);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Hapus Siswa',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _handleDeleteSiswa(siswa);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteSiswa(Siswa siswa) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Siswa',
      message:
          'Yakin ingin menghapus "${siswa.nama}" (NIS ${siswa.nis}) dari kelas ini? Tindakan ini tidak dapat dibatalkan.',
    );
    if (!confirmed || !mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final res = await KelasService.instance.deleteSiswa(siswa.id);
    if (!mounted) return;

    if (res.success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty ? res.message : 'Siswa berhasil dihapus',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData();
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _handleDownloadExcel(GameTokenItem token) async {
    setState(() => _downloadingTokenId = token.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mengunduh rekap nilai Excel (${token.kodeToken})...'),
        duration: const Duration(seconds: 2),
      ),
    );

    final res = await NilaiSubBabService.instance.downloadExportExcelToken(
      token.id,
      fileName: 'Rekap_Nilai_${token.kodeToken}.xlsx',
    );

    if (!mounted) return;
    setState(() => _downloadingTokenId = null);

    if (res.success && res.data != null) {
      final file = res.data!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Disimpan di folder Download:\n${file.path.split(Platform.pathSeparator).last}',
          ),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'Buka',
            textColor: Colors.white,
            onPressed: () => OpenFilex.open(file.path),
          ),
        ),
      );

      final openRes = await OpenFilex.open(file.path);
      if (openRes.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File berhasil diunduh. Info: ${openRes.message}',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty ? res.message : 'Gagal mengunduh Excel',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSiswaFormModal({Siswa? siswa}) {
    final isEdit = siswa != null;
    final defaultSekolah = _currentKelas.sekolah.isNotEmpty
        ? _currentKelas.sekolah
        : (AppData.instance.guruDashboardData?.profil.sekolah?.namaSekolah ??
              AppData.instance.currentGuru?.sekolah ??
              '');
    final defaultSekolahId =
        _currentKelas.sekolahId ??
        AppData.instance.guruDashboardData?.profil.sekolahId ??
        AppData.instance.guruDashboardData?.profil.sekolah?.id ??
        '';

    final namaCtrl = TextEditingController(text: isEdit ? siswa.nama : '');
    final nisCtrl = TextEditingController(text: isEdit ? siswa.nis : '');

    bool isSubmitting = false;
    String? formError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isEdit ? 'Edit Siswa' : 'Tambah Siswa',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (formError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 18,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                formError!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    AppInput(
                      label: 'Nama Siswa',
                      hint: 'Contoh: Budi Pratama',
                      controller: namaCtrl,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      label: 'NIS (Nomor Induk Siswa)',
                      hint: 'Contoh: 102938',
                      controller: nisCtrl,
                      keyboardType: TextInputType.number,
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: isEdit ? 'Simpan Perubahan' : 'Tambah Siswa',
                      isLoading: isSubmitting,
                      onPressed: () async {
                        final nama = namaCtrl.text.trim();
                        final nis = nisCtrl.text.trim();

                        if (nama.isEmpty || nis.isEmpty) {
                          setModalState(() {
                            formError = 'Nama siswa dan NIS wajib diisi';
                          });
                          return;
                        }

                        setModalState(() {
                          isSubmitting = true;
                          formError = null;
                        });

                        final scaffoldMessenger = ScaffoldMessenger.of(
                          this.context,
                        );
                        ApiResponse<void> res;

                        if (isEdit) {
                          res = await KelasService.instance.updateSiswa(
                            id: siswa.id,
                            namaSiswa: nama,
                            nis: nis,
                            sekolahId: siswa.sekolahId ?? defaultSekolahId,
                            namaSekolah: siswa.sekolah.isNotEmpty
                                ? siswa.sekolah
                                : defaultSekolah,
                            kodeKelas: siswa.kelas.isNotEmpty
                                ? siswa.kelas
                                : _currentKelas.kodeKelas,
                            kelasId: _currentKelas.id,
                          );
                        } else {
                          res = await KelasService.instance.createSiswa(
                            namaSiswa: nama,
                            nis: nis,
                            namaSekolah: defaultSekolah,
                            kodeKelas: _currentKelas.kodeKelas,
                            sekolahId: defaultSekolahId,
                            kelasId: _currentKelas.id,
                          );
                        }

                        if (!mounted) return;

                        if (res.success) {
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                res.message.isNotEmpty
                                    ? res.message
                                    : (isEdit
                                          ? 'Data siswa berhasil diperbarui'
                                          : 'Siswa berhasil ditambahkan'),
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          _loadData();
                        } else {
                          setModalState(() {
                            isSubmitting = false;
                            formError = res.message;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final guruPengampu = _currentKelas.guruPengampu.isNotEmpty
        ? _currentKelas.guruPengampu
        : (AppData.instance.guruDashboardData?.profil.namaGuru ??
              AppData.instance.currentGuru?.nama ??
              '-');

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentKelas.namaKelas),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: _selectedTabIndex == 0
            ? 'fab_detail_kelas_siswa'
            : 'fab_detail_kelas_token',
        onPressed: _selectedTabIndex == 0
            ? () => _showSiswaFormModal()
            : () => _openBuatToken(),
        icon: Icon(_selectedTabIndex == 0 ? Icons.person_add_alt_1 : Icons.add),
        label: Text(_selectedTabIndex == 0 ? 'Tambah Siswa' : 'Buat Token Ujian'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: [
            // Info Kelas Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow(
                    icon: Icons.person_outline,
                    label: 'Guru Pengampu',
                    value: guruPengampu,
                  ),
                  const Divider(),
                  InfoRow(
                    icon: Icons.groups_outlined,
                    label: 'Jumlah Siswa',
                    value: '${_siswaList.length} siswa',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Selector: Siswa vs Token Ujian (2 Tab)
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0
                              ? AppColors.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedTabIndex == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_alt_outlined,
                              size: 16,
                              color: _selectedTabIndex == 0
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Siswa (${_siswaList.length})',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selectedTabIndex == 0
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: _selectedTabIndex == 0
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1
                              ? AppColors.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedTabIndex == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.vpn_key_rounded,
                              size: 16,
                              color: _selectedTabIndex == 1
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Token Ujian (${_tokenList.length})',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selectedTabIndex == 1
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: _selectedTabIndex == 1
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 16),

            // ── TAB 0: DAFTAR SISWA ──────────────────────────────────────────
            if (_selectedTabIndex == 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Siswa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    '${_siswaList.length} Siswa',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isLoading && _siswaList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: LoadingState(message: 'Memuat data siswa...'),
                  ),
                )
              else if (_siswaList.isEmpty)
                EmptyState(
                  icon: Icons.people_outline,
                  title: 'Belum ada data siswa',
                  message:
                      _errorMessage ??
                      'Belum ada siswa di kelas ini. Tekan tombol Tambah Siswa untuk mendaftarkan siswa baru.',
                )
              else
                ..._siswaList.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => _showSiswaOptions(s),
                      child: InkWell(
                        onLongPress: () => _showSiswaOptions(s),
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          children: [
                            AppAvatar(name: s.nama, size: 42),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.nama,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'NIS: ${s.nis}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.more_vert,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => _showSiswaOptions(s),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ]

            // ── TAB 1: TOKEN UJIAN ───────────────────────────────────────────
            else if (_selectedTabIndex == 1) ...[
              // Banner Tombol Buat Token Baru
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _openBuatToken,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_task_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Buat Token Ujian Baru',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Rilis paket soal & kode token baru untuk kelas ini',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Token Ujian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    '${_tokenList.length} Token',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading && _tokenList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: LoadingState(message: 'Memuat token ujian...'),
                  ),
                )
              else if (_tokenList.isEmpty)
                EmptyState(
                  icon: Icons.vpn_key_outlined,
                  title: 'Belum ada token ujian',
                  message:
                      'Belum ada token ujian yang dibuat untuk kelas ini. Tekan tombol Buat Token Ujian Baru untuk merilis ujian.',
                )
              else
                ..._tokenList.map(
                  (token) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RekapNilaiUjianScreen(
                              tokenId: token.id,
                              kodeToken: token.kodeToken,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  token.namaSesi,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Status: Aktif / Nonaktif
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: token.aktif
                                      ? AppColors.success.withValues(alpha: 0.12)
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  token.aktif ? 'Aktif' : 'Nonaktif',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: token.aktif
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Badge Kode Token (Teks tebal dengan background kontras) + icon Salin
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'KODE TOKEN: ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    token.kodeToken,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: token.kodeToken),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Kode token ${token.kodeToken} disalin!',
                                        ),
                                        backgroundColor: AppColors.success,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.copy_rounded,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Salin',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Info Chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (token.semester != null)
                                _buildTokenInfoChip(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Semester ${token.semester}',
                                ),
                              _buildTokenInfoChip(
                                icon: Icons.quiz_outlined,
                                label: '${token.jumlahSoal} Soal',
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // Tombol "Download Rekap Excel" dan "Rekap Nilai"
                          Row(
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.success
                                        .withValues(alpha: 0.5),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  foregroundColor: AppColors.success,
                                ),
                                onPressed: _downloadingTokenId == token.id
                                    ? null
                                    : () => _handleDownloadExcel(token),
                                icon: _downloadingTokenId == token.id
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.success,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.table_view_outlined,
                                        size: 16,
                                      ),
                                label: Text(
                                  _downloadingTokenId == token.id
                                      ? 'Mengunduh...'
                                      : 'Download Excel',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => RekapNilaiUjianScreen(
                                        tokenId: token.id,
                                        kodeToken: token.kodeToken,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.analytics_outlined,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Lihat Nilai',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

