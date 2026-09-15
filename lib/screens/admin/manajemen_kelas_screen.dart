import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/auth_user.dart';
import '../../models/guru.dart';
import '../../models/kelas.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../services/kelas_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../auth/login_screen.dart';

/// Screen for managing Classes (CRUD Kelas) for Admin role.
/// Includes class listing, search, creation, edition, and deletion.
/// EXCLUDES any student registration / "tambah murid" functionality.
class ManajemenKelasScreen extends StatefulWidget {
  const ManajemenKelasScreen({super.key});

  @override
  State<ManajemenKelasScreen> createState() => _ManajemenKelasScreenState();
}

class _ManajemenKelasScreenState extends State<ManajemenKelasScreen> {
  final _searchController = TextEditingController();
  List<Kelas> _kelasList = [];
  List<Guru> _guruList = [];
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

  Future<void> _loadData({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = await Future.wait([
        KelasService.instance.getKelas(),
        AdminService.instance.getGuruList(page: 1, limit: 100),
      ]);

      if (!mounted) return;

      final kelasRes = futures[0] as dynamic;
      final guruRes = futures[1] as dynamic;

      setState(() {
        _isLoading = false;
        if (kelasRes.success && kelasRes.data != null) {
          _kelasList = List<Kelas>.from(kelasRes.data as List);
        } else {
          _errorMessage = kelasRes.message;
        }

        if (guruRes.success && guruRes.data != null) {
          _guruList = List<Guru>.from(guruRes.data!.data);
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

  Future<void> _handleDeleteKelas(Kelas kelas) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus',
      message:
          'Yakin ingin menghapus kelas "${kelas.namaKelas}" (${kelas.kodeKelas})? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDangerous: true,
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
      _loadData(isRefresh: true);
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.error),
      );
    }
  }

  void _showKelasFormModal({Kelas? kelas}) {
    final isEdit = kelas != null;
    final currentUser = AppData.instance.currentUser;
    final profil = currentUser?.profil;
    String defaultSekolah = '';
    String defaultSekolahId = '';
    if (currentUser?.sekolah is String) {
      defaultSekolah = currentUser!.sekolah as String;
    } else if (currentUser?.sekolah is Map) {
      final sMap = currentUser!.sekolah as Map;
      defaultSekolah = sMap['nama_sekolah']?.toString() ?? '';
      defaultSekolahId = sMap['id']?.toString() ?? '';
    }
    if (defaultSekolahId.isEmpty && profil != null) {
      defaultSekolahId = profil['sekolah_id']?.toString() ?? '';
    }

    final kodeCtrl = TextEditingController(text: isEdit ? kelas.kodeKelas : '');
    final namaCtrl = TextEditingController(text: isEdit ? kelas.namaKelas : '');
    int selectedTingkat = isEdit ? kelas.tingkat : 10;
    String? selectedGuruId = isEdit ? (kelas.guruId ?? '') : null;
    if (selectedGuruId != null && selectedGuruId.isEmpty) {
      selectedGuruId = null;
    }

    // Verify selectedGuruId exists in _guruList
    if (selectedGuruId != null &&
        !_guruList.any((g) => g.id == selectedGuruId)) {
      selectedGuruId = null;
    }

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
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.class_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEdit ? 'Edit Kelas' : 'Tambah Kelas Baru',
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

                    // Error Box
                    if (formError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
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
                      const SizedBox(height: 14),
                    ],

                    // Info Sekolah
                    if (defaultSekolah.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.apartment_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                defaultSekolah,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Kode Kelas
                    AppInput(
                      label: 'Kode Kelas',
                      hint: 'Contoh: X-IPA-1, XI-RPL, XII-IPS-2',
                      controller: kodeCtrl,
                      icon: Icons.qr_code_outlined,
                    ),
                    const SizedBox(height: 14),

                    // Nama Kelas
                    AppInput(
                      label: 'Nama Kelas',
                      hint: 'Contoh: Kelas X IPA 1',
                      controller: namaCtrl,
                      icon: Icons.meeting_room_outlined,
                    ),
                    const SizedBox(height: 14),

                    // Tingkat Selector
                    const Text(
                      'Tingkat Kelas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [10, 11, 12].map((lvl) {
                        final isSelected = selectedTingkat == lvl;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () {
                                setModalState(() => selectedTingkat = lvl);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Kelas $lvl',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.text,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Guru Pengampu Dropdown
                    const Text(
                      'Guru Pengampu (Opsional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedGuruId,
                          isExpanded: true,
                          hint: const Text(
                            'Pilih Guru Pengampu',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                '-- Belum Ditentukan (Kosongkan) --',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            ..._guruList.map((guru) {
                              return DropdownMenuItem<String?>(
                                value: guru.id,
                                child: Text(
                                  '${guru.namaGuru} (${guru.nim})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setModalState(() => selectedGuruId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
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
                            guruId: selectedGuruId ?? '',
                            namaSekolah: defaultSekolah.isNotEmpty
                                ? defaultSekolah
                                : kelas.sekolah,
                            tingkat: selectedTingkat,
                          );
                        } else {
                          res = await KelasService.instance.createKelas(
                            kodeKelas: kode,
                            namaKelas: nama,
                            namaSekolah: defaultSekolah,
                            sekolahId: defaultSekolahId,
                            guruId: selectedGuruId,
                            tingkat: selectedTingkat,
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
                          _loadData(isRefresh: true);
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

  void _showKelasDetailModal(Kelas kelas) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.class_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kelas.namaKelas,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          'Kode: ${kelas.kodeKelas} • Tingkat ${kelas.tingkat}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              AppCard(
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.person_outline,
                      label: 'Guru Pengampu',
                      value: kelas.guruPengampu.isNotEmpty
                          ? kelas.guruPengampu
                          : 'Belum ditentukan',
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.apartment_outlined,
                      label: 'Sekolah',
                      value: kelas.sekolah.isNotEmpty
                          ? kelas.sekolah
                          : 'Sekolah Terdaftar',
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.groups_outlined,
                      label: 'Jumlah Siswa Terdaftar',
                      value: '${kelas.jumlahSiswa} siswa',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      variant: AppButtonVariant.outlined,
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _showKelasFormModal(kelas: kelas);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Hapus',
                      icon: Icons.delete_outline,
                      variant: AppButtonVariant.danger,
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _handleDeleteKelas(kelas);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keluar Akun',
      message: 'Anda yakin ingin keluar dari akun administrator?',
      confirmLabel: 'Keluar',
      isDangerous: true,
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
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _kelasList
        : _kelasList.where((k) {
            final q = _searchQuery.toLowerCase();
            return k.namaKelas.toLowerCase().contains(q) ||
                k.kodeKelas.toLowerCase().contains(q) ||
                k.guruPengampu.toLowerCase().contains(q) ||
                k.sekolah.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kelas'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: () => _loadData(isRefresh: true),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Keluar Akun',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_manajemen_kelas',
        onPressed: () => _showKelasFormModal(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Kelas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(isRefresh: true),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppSearchBar(
                controller: _searchController,
                hint: 'Cari nama kelas, kode, atau guru...',
                onChanged: (v) {
                  setState(() => _searchQuery = v);
                },
              ),
            ),

            // Summary Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Menampilkan ${filtered.length} kelas',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Class List
            Expanded(
              child: _isLoading && _kelasList.isEmpty
                  ? const Center(
                      child: LoadingState(message: 'Memuat data kelas...'),
                    )
                  : _kelasList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.class_outlined,
                          title: 'Belum ada data kelas',
                          message:
                              _errorMessage ??
                              'Tekan tombol Tambah Kelas untuk membuat kelas baru di sekolah Anda.',
                        ),
                      ],
                    )
                  : filtered.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'Kelas tidak ditemukan',
                          message:
                              'Coba gunakan kata kunci pencarian yang lain.',
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final k = filtered[idx];
                        return AppCard(
                          onTap: () => _showKelasDetailModal(k),
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
                                  // Tingkat Chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Kelas ${k.tingkat}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Kode Kelas Chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
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
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 20,
                                      color: AppColors.textSecondary,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onSelected: (action) {
                                      if (action == 'edit') {
                                        _showKelasFormModal(kelas: k);
                                      } else if (action == 'delete') {
                                        _handleDeleteKelas(k);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Guru Pengampu Row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      k.guruPengampu.isNotEmpty
                                          ? 'Pengampu: ${k.guruPengampu}'
                                          : 'Pengampu: Belum ditentukan',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: k.guruPengampu.isNotEmpty
                                            ? AppColors.text
                                            : AppColors.textSecondary,
                                        fontStyle: k.guruPengampu.isNotEmpty
                                            ? FontStyle.normal
                                            : FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Jumlah Siswa Row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.groups_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    k.jumlahSiswa > 0
                                        ? '${k.jumlahSiswa} siswa terdaftar'
                                        : 'Belum ada siswa',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'Detail',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ],
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
