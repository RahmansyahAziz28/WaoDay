import 'package:flutter/material.dart';

import '../../models/guru.dart';
import '../../models/sekolah.dart';
import '../../services/admin_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class ManajemenGuruScreen extends StatefulWidget {
  const ManajemenGuruScreen({super.key});

  @override
  State<ManajemenGuruScreen> createState() => _ManajemenGuruScreenState();
}

class _ManajemenGuruScreenState extends State<ManajemenGuruScreen> {
  final _searchController = TextEditingController();
  List<Guru> _guruList = [];
  List<Sekolah> _sekolahList = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = await Future.wait([
        AdminService.instance.getGuruList(page: 1, limit: 100),
        AdminService.instance.getSekolahList(),
      ]);

      if (!mounted) return;

      final guruRes = futures[0] as dynamic;
      final sekolahRes = futures[1] as dynamic;

      setState(() {
        _isLoading = false;
        if (guruRes.success && guruRes.data != null) {
          _guruList = guruRes.data as List<Guru>;
        } else {
          _errorMessage = guruRes.message;
        }

        if (sekolahRes.success && sekolahRes.data != null) {
          _sekolahList = sekolahRes.data as List<Sekolah>;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  void _showGuruDetail(Guru guru) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            AppAvatar(name: guru.namaGuru, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guru.namaGuru,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'NIM: ${guru.nim}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              InfoRow(
                icon: Icons.apartment_outlined,
                label: 'Sekolah',
                value: guru.sekolah.isNotEmpty ? guru.sekolah : '-',
              ),
              const Divider(),
              InfoRow(
                icon: Icons.badge_outlined,
                label: 'NIM Guru',
                value: guru.nim,
              ),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Kelas yang Diampu:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              if (guru.kelasList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Belum ada kelas yang diasosiasikan.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                )
              else
                ...guru.kelasList.map(
                  (k) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.class_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            k.namaKelas,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          k.kodeKelas,
                          style: const TextStyle(
                            fontSize: 11,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showGuruFormModal(guru: guru);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showGuruOptions(Guru guru) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    AppAvatar(name: guru.namaGuru, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guru.namaGuru,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            '${guru.nim} · ${guru.sekolah}',
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
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                title: const Text('Lihat Detail Guru & Kelas'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showGuruDetail(guru);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.secondary),
                title: const Text('Edit Data Guru'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showGuruFormModal(guru: guru);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Hapus Guru', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _handleDeleteGuru(guru);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteGuru(Guru guru) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Guru',
      message:
          'Yakin ingin menghapus guru "${guru.namaGuru}" (NIM: ${guru.nim})? Tindakan ini tidak dapat dibatalkan.',
    );
    if (!confirmed || !mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final res = await AdminService.instance.deleteGuru(guru.id);
    if (!mounted) return;

    if (res.success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(res.message.isNotEmpty ? res.message : 'Guru berhasil dihapus'),
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

  void _showGuruFormModal({Guru? guru}) {
    final isEdit = guru != null;
    final namaCtrl = TextEditingController(text: isEdit ? guru.namaGuru : '');
    final nimCtrl = TextEditingController(text: isEdit ? guru.nim : '');
    final sekolahCtrl = TextEditingController(
      text: isEdit
          ? guru.sekolah
          : (_sekolahList.isNotEmpty ? _sekolahList.first.namaSekolah : ''),
    );
    final kodeKelasCtrl = TextEditingController(
      text: isEdit
          ? (guru.kelasList.isNotEmpty ? guru.kelasList.first.kodeKelas : guru.kodeKelas)
          : 'X-IPA-1',
    );
    final sekolahIdCtrl = TextEditingController(
      text: isEdit ? (guru.sekolahId ?? '') : (_sekolahList.isNotEmpty ? _sekolahList.first.id : ''),
    );

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
                          isEdit ? 'Edit Data Guru' : 'Tambah Guru Baru',
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
                      label: 'Nama Guru Lengkap',
                      hint: 'Contoh: Budi Raharjo, S.Pd',
                      controller: namaCtrl,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      label: 'NIM / NIP Guru',
                      hint: 'Contoh: GR6281 atau 198234',
                      controller: nimCtrl,
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 14),
                    if (!isEdit) ...[
                      AppInput(
                        label: 'Nama Sekolah',
                        hint: 'Contoh: SMA Negeri 1 Jakarta',
                        controller: sekolahCtrl,
                        icon: Icons.apartment_outlined,
                      ),
                      const SizedBox(height: 14),
                      AppInput(
                        label: 'Kode Kelas Awal',
                        hint: 'Contoh: X-IPA-1',
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
                      label: isEdit ? 'Simpan Perubahan' : 'Tambah Guru',
                      isLoading: isSubmitting,
                      onPressed: () async {
                        final nama = namaCtrl.text.trim();
                        final nim = nimCtrl.text.trim();
                        final sekolah = sekolahCtrl.text.trim();
                        final kodeKelas = kodeKelasCtrl.text.trim();
                        final sekolahId = sekolahIdCtrl.text.trim();

                        if (nama.isEmpty || nim.isEmpty) {
                          setModalState(() {
                            formError = 'Nama guru dan NIM wajib diisi';
                          });
                          return;
                        }

                        if (!isEdit && (sekolah.isEmpty || kodeKelas.isEmpty)) {
                          setModalState(() {
                            formError = 'Nama sekolah dan kode kelas awal wajib diisi';
                          });
                          return;
                        }

                        setModalState(() {
                          isSubmitting = true;
                          formError = null;
                        });

                        final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                        dynamic res;

                        if (isEdit) {
                          res = await AdminService.instance.updateGuru(
                            guru.id,
                            namaGuru: nama,
                            nim: nim,
                            sekolahId: sekolahId.isNotEmpty ? sekolahId : (guru.sekolahId ?? ''),
                          );
                        } else {
                          res = await AdminService.instance.createGuru(
                            namaGuru: nama,
                            nim: nim,
                            namaSekolah: sekolah,
                            kodeKelas: kodeKelas,
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
                                    : (isEdit ? 'Data guru berhasil diperbarui' : 'Guru berhasil ditambahkan'),
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
    final filtered = _searchQuery.isEmpty
        ? _guruList
        : _guruList.where((g) {
            final q = _searchQuery.toLowerCase();
            return g.namaGuru.toLowerCase().contains(q) ||
                g.nim.toLowerCase().contains(q) ||
                g.sekolah.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Guru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGuruFormModal(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Guru'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppSearchBar(
                controller: _searchController,
                hint: 'Cari nama, NIM, atau sekolah...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            Expanded(
              child: _isLoading && _guruList.isEmpty
                  ? const Center(child: LoadingState(message: 'Memuat data guru...'))
                  : _guruList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            EmptyState(
                              icon: Icons.people_outline,
                              title: 'Belum ada data guru',
                              message: _errorMessage ??
                                  'Tekan tombol Tambah Guru untuk mendaftarkan akun pengajar baru.',
                            ),
                          ],
                        )
                      : filtered.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 80),
                                EmptyState(
                                  icon: Icons.search_off,
                                  title: 'Tidak ditemukan',
                                  message: 'Tidak ada guru yang cocok dengan kriteria pencarian.',
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final g = filtered[index];
                                return AppCard(
                                  onTap: () => _showGuruOptions(g),
                                  child: InkWell(
                                    onLongPress: () => _showGuruOptions(g),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            AppAvatar(name: g.namaGuru, size: 44),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    g.namaGuru,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.text,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'NIM: ${g.nim}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.primary,
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
                                              onPressed: () => _showGuruOptions(g),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.apartment_outlined,
                                              size: 15,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                g.sekolah.isNotEmpty ? g.sekolah : 'Sekolah belum diatur',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (g.kelasList.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: g.kelasList.map((k) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  k.namaKelas.isNotEmpty ? k.namaKelas : k.kodeKelas,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.secondary,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
