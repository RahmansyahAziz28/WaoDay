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

  void _showKelasOptions(Kelas kelas) {
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
                    Expanded(
                      child: Text(
                        kelas.namaKelas,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Text(
                      kelas.kodeKelas,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
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
                title: const Text('Edit Kelas'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _showKelasFormModal(kelas: kelas);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Hapus Kelas',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _handleDeleteKelas(kelas);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteKelas(Kelas kelas) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Kelas',
      message:
          'Yakin ingin menghapus kelas "${kelas.namaKelas}" (${kelas.kodeKelas})? Tindakan ini tidak dapat dibatalkan.',
    );
    if (!confirmed || !mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final res = await KelasService.instance.deleteKelas(kelas.id);
    if (!mounted) return;

    if (res.success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty ? res.message : 'Kelas berhasil dihapus',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      _loadKelas();
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.error),
      );
    }
  }

  void _showKelasFormModal({Kelas? kelas}) {
    final isEdit = kelas != null;
    final defaultSekolah =
        AppData.instance.guruDashboardData?.profil.sekolah?.namaSekolah ??
        AppData.instance.currentGuru?.sekolah ??
        '';
    final defaultSekolahId =
        AppData.instance.guruDashboardData?.profil.sekolahId ??
        AppData.instance.guruDashboardData?.profil.sekolah?.id ??
        '';
    final defaultGuruId =
        AppData.instance.guruDashboardData?.profil.id ??
        AppData.instance.currentUser?.id ??
        '';

    final kodeCtrl = TextEditingController(text: isEdit ? kelas.kodeKelas : '');
    final namaCtrl = TextEditingController(text: isEdit ? kelas.namaKelas : '');

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
            final displaySekolah = (isEdit && kelas.sekolah.isNotEmpty)
                ? kelas.sekolah
                : (defaultSekolah.isNotEmpty
                      ? defaultSekolah
                      : 'Sekolah Guru Terdaftar');

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
                          isEdit ? 'Edit Kelas' : 'Tambah Kelas',
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
                    // Otomatis Sekolah Guru
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.apartment_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sekolah',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displaySekolah,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      label: 'Kode Kelas',
                      hint: 'Contoh: XIPA1, XII-RPL1',
                      controller: kodeCtrl,
                      icon: Icons.qr_code_outlined,
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      label: 'Nama Kelas',
                      hint: 'Contoh: Kelas X IPA 1',
                      controller: namaCtrl,
                      icon: Icons.class_outlined,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: isEdit ? 'Simpan Perubahan' : 'Tambah Kelas',
                      isLoading: isSubmitting,
                      onPressed: () async {
                        final kode = kodeCtrl.text.trim();
                        final nama = namaCtrl.text.trim();

                        if (kode.isEmpty || nama.isEmpty) {
                          setModalState(() {
                            formError = 'Kode kelas dan nama kelas wajib diisi';
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
                          res = await KelasService.instance.updateKelas(
                            id: kelas.id,
                            kodeKelas: kode,
                            namaKelas: nama,
                            sekolahId: defaultSekolahId.isNotEmpty
                                ? defaultSekolahId
                                : (kelas.sekolahId ?? ''),
                            guruId: defaultGuruId.isNotEmpty
                                ? defaultGuruId
                                : (kelas.guruId ?? ''),
                            namaSekolah: defaultSekolah.isNotEmpty
                                ? defaultSekolah
                                : kelas.sekolah,
                          );
                        } else {
                          res = await KelasService.instance.createKelas(
                            kodeKelas: kode,
                            namaKelas: nama,
                            namaSekolah: defaultSekolah,
                            sekolahId: defaultSekolahId,
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
                                          ? 'Kelas berhasil diperbarui'
                                          : 'Kelas berhasil ditambahkan'),
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          _loadKelas();
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_kelas_saya',
        onPressed: () => _showKelasFormModal(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kelas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                        'Anda belum membuat atau ditugaskan mengampu kelas apapun. Tekan tombol Tambah Kelas untuk membuat kelas baru.',
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
                    onLongPress: () => _showKelasOptions(k),
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
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.more_vert,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => _showKelasOptions(k),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
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
