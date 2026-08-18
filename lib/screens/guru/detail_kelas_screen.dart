import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/models.dart';
import '../../services/kelas_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class DetailKelasScreen extends StatefulWidget {
  const DetailKelasScreen({super.key, required this.kelas});

  final Kelas kelas;

  @override
  State<DetailKelasScreen> createState() => _DetailKelasScreenState();
}

class _DetailKelasScreenState extends State<DetailKelasScreen> {
  late Kelas _currentKelas;
  List<Siswa> _siswaList = [];
  bool _isLoading = false;
  String? _errorMessage;

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
      ]);

      if (!mounted) return;

      final detailRes = futures[0] as ApiResponse<Kelas>;
      final siswaRes = futures[1] as ApiResponse<List<Siswa>>;

      setState(() {
        _isLoading = false;
        if (detailRes.success && detailRes.data != null) {
          _currentKelas = detailRes.data!;
        }
        if (siswaRes.success && siswaRes.data != null) {
          _siswaList = siswaRes.data!;
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                title: const Text('Edit Siswa'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _showSiswaFormModal(siswa: siswa);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Hapus Siswa', style: TextStyle(color: AppColors.error)),
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
          content: Text(res.message.isNotEmpty ? res.message : 'Siswa berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData();
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(res.message),
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
    final defaultSekolahId = _currentKelas.sekolahId ??
        AppData.instance.guruDashboardData?.profil.sekolahId ??
        AppData.instance.guruDashboardData?.profil.sekolah?.id ??
        '';

    final namaCtrl = TextEditingController(text: isEdit ? siswa.nama : '');
    final nisCtrl = TextEditingController(text: isEdit ? siswa.nis : '');
    final sekolahCtrl = TextEditingController(
      text: isEdit ? siswa.sekolah : defaultSekolah,
    );
    final kodeKelasCtrl = TextEditingController(
      text: isEdit ? siswa.kelas : _currentKelas.kodeKelas,
    );
    final sekolahIdCtrl = TextEditingController(text: defaultSekolahId);

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
                            const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                formError!,
                                style: const TextStyle(fontSize: 13, color: AppColors.error),
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
                    const SizedBox(height: 14),
                    if (!isEdit) ...[
                      AppInput(
                        label: 'Nama Sekolah',
                        hint: 'Nama Sekolah',
                        controller: sekolahCtrl,
                        icon: Icons.apartment_outlined,
                      ),
                      const SizedBox(height: 14),
                      AppInput(
                        label: 'Kode Kelas',
                        hint: 'Kode Kelas',
                        controller: kodeKelasCtrl,
                        icon: Icons.qr_code_outlined,
                      ),
                    ] else ...[
                      AppInput(
                        label: 'Sekolah ID',
                        hint: 'ID Sekolah',
                        controller: sekolahIdCtrl,
                        icon: Icons.apartment_outlined,
                      ),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      label: isEdit ? 'Simpan Perubahan' : 'Tambah Siswa',
                      isLoading: isSubmitting,
                      onPressed: () async {
                        final nama = namaCtrl.text.trim();
                        final nis = nisCtrl.text.trim();
                        final sekolah = sekolahCtrl.text.trim();
                        final kodeKelas = kodeKelasCtrl.text.trim();
                        final sekolahId = sekolahIdCtrl.text.trim();

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

                        final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                        ApiResponse<void> res;

                        if (isEdit) {
                          res = await KelasService.instance.updateSiswa(
                            id: siswa.id,
                            namaSiswa: nama,
                            nis: nis,
                            sekolahId: sekolahId.isNotEmpty ? sekolahId : defaultSekolahId,
                          );
                        } else {
                          res = await KelasService.instance.createSiswa(
                            namaSiswa: nama,
                            nis: nis,
                            namaSekolah: sekolah.isNotEmpty ? sekolah : defaultSekolah,
                            kodeKelas: kodeKelas.isNotEmpty ? kodeKelas : _currentKelas.kodeKelas,
                          );
                        }

                        if (!mounted) return;

                        if (res.success) {
                          Navigator.of(sheetContext).pop();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                res.message.isNotEmpty
                                    ? res.message
                                    : (isEdit ? 'Data siswa berhasil diperbarui' : 'Siswa berhasil ditambahkan'),
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
    final namaSekolah = _currentKelas.sekolah.isNotEmpty
        ? _currentKelas.sekolah
        : (AppData.instance.guruDashboardData?.profil.sekolah?.namaSekolah ?? '-');
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
        onPressed: () => _showSiswaFormModal(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah Siswa'),
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
                    icon: Icons.qr_code_outlined,
                    label: 'Kode Kelas',
                    value: _currentKelas.kodeKelas,
                  ),
                  const Divider(),
                  InfoRow(
                    icon: Icons.class_outlined,
                    label: 'Nama Kelas',
                    value: _currentKelas.namaKelas,
                  ),
                  const Divider(),
                  InfoRow(
                    icon: Icons.apartment_outlined,
                    label: 'Sekolah',
                    value: namaSekolah,
                  ),
                  const Divider(),
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
            const SizedBox(height: 24),

            // Header Daftar Siswa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Daftar Siswa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_siswaList.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showSiswaFormModal(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_isLoading && _siswaList.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: LoadingState(message: 'Memuat data siswa...')),
              )
            else if (_siswaList.isEmpty)
              EmptyState(
                icon: Icons.people_outline,
                title: 'Belum ada data siswa',
                message: _errorMessage ??
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
          ],
        ),
      ),
    );
  }
}
