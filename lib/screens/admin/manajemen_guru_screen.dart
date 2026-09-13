import 'package:flutter/material.dart';

import '../../models/guru.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../auth/login_screen.dart';

/// Screen for managing teachers (CRUD Guru) for Admin role.
class ManajemenGuruScreen extends StatefulWidget {
  const ManajemenGuruScreen({super.key});

  @override
  State<ManajemenGuruScreen> createState() => _ManajemenGuruScreenState();
}

class _ManajemenGuruScreenState extends State<ManajemenGuruScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  List<Guru> _guruList = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';
  String? _errorMessage;

  // Pagination state
  int _currentPage = 1;
  int _limit = 20;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= (maxScroll - 200)) {
      _loadMoreData();
    }
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _errorMessage = null;
      if (isRefresh) {
        _currentPage = 1;
        _hasMore = true;
      }
    });

    try {
      final res = await AdminService.instance.getGuruList(
        page: 1,
        limit: _limit > 0 ? _limit : 20,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (res.success && res.data != null) {
          _guruList = List.from(res.data!.data);
          _totalCount = res.data!.count;
          _currentPage = res.data!.page;
          _limit = res.data!.limit > 0 ? res.data!.limit : 20;
          _hasMore =
              _guruList.length < _totalCount && res.data!.data.isNotEmpty;
        } else {
          _errorMessage = res.message;
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

  Future<void> _loadMoreData() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;
    try {
      final res = await AdminService.instance.getGuruList(
        page: nextPage,
        limit: _limit > 0 ? _limit : 20,
      );

      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
        if (res.success && res.data != null) {
          final newItems = res.data!.data;
          final existingIds = _guruList.map((g) => g.id).toSet();
          for (final item in newItems) {
            if (!existingIds.contains(item.id)) {
              _guruList.add(item);
            }
          }
          _totalCount = res.data!.count;
          _currentPage = res.data!.page;
          _hasMore = _guruList.length < _totalCount && newItems.isNotEmpty;
        } else {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
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
            AppAvatar(
              name: guru.namaGuru.isNotEmpty ? guru.namaGuru : 'Guru',
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guru.namaGuru.isNotEmpty ? guru.namaGuru : 'Tanpa Nama',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'NIM: ${guru.nim.isNotEmpty ? guru.nim : '-'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
                label: 'Nama Sekolah',
                value: guru.sekolah.isNotEmpty ? guru.sekolah : '-',
              ),
              const Divider(),
              InfoRow(
                icon: Icons.fingerprint_outlined,
                label: 'Sekolah ID',
                value: (guru.sekolahId != null && guru.sekolahId!.isNotEmpty)
                    ? guru.sekolahId!
                    : (guru.sekolahInfo?.id.isNotEmpty == true
                          ? guru.sekolahInfo!.id
                          : '-'),
              ),
              const Divider(),
              InfoRow(
                icon: Icons.badge_outlined,
                label: 'NIM / NIP Guru',
                value: guru.nim.isNotEmpty ? guru.nim : '-',
              ),
              if (guru.createdAt != null && guru.createdAt!.isNotEmpty) ...[
                const Divider(),
                InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Didaftarkan',
                  value: guru.createdAt!.split('T').first,
                ),
              ],
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Belum ada kelas yang diasosiasikan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ...guru.kelasList.map(
                  (k) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.class_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            k.namaKelas.isNotEmpty ? k.namaKelas : k.kodeKelas,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showGuruFormModal(guru: guru);
            },
            child: const Text('Edit Guru'),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    AppAvatar(
                      name: guru.namaGuru.isNotEmpty ? guru.namaGuru : 'Guru',
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guru.namaGuru.isNotEmpty
                                ? guru.namaGuru
                                : 'Tanpa Nama',
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
                leading: const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                ),
                title: const Text('Lihat Detail Guru & Kelas'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showGuruDetail(guru);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.secondary,
                ),
                title: const Text('Edit Data Guru'),
                subtitle: const Text('Ubah nama, NIM, atau sekolah ID'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showGuruFormModal(guru: guru);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Hapus Guru',
                  style: TextStyle(color: AppColors.error),
                ),
                subtitle: const Text('Hapus akun pengajar dari sistem'),
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
          content: Text(
            res.message.isNotEmpty ? res.message : 'Guru berhasil dihapus',
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

  void _showGuruFormModal({Guru? guru}) {
    final isEdit = guru != null;
    final namaCtrl = TextEditingController(text: isEdit ? guru.namaGuru : '');
    final nimCtrl = TextEditingController(text: isEdit ? guru.nim : '');
    final sekolahCtrl = TextEditingController(text: isEdit ? guru.sekolah : '');
    final kodeKelasCtrl = TextEditingController(
      text: isEdit
          ? (guru.kelasList.isNotEmpty
                ? guru.kelasList.first.kodeKelas
                : guru.kodeKelas)
          : 'X-IPA-1',
    );
    final sekolahIdCtrl = TextEditingController(
      text: isEdit ? (guru.sekolahId ?? guru.sekolahInfo?.id ?? '') : '',
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
                        hint: 'Contoh: SMA Negeri 1 Indonesia 4860',
                        controller: sekolahCtrl,
                        icon: Icons.apartment_outlined,
                      ),
                      const SizedBox(height: 14),
                      AppInput(
                        label: 'Kode Kelas Awal',
                        hint: 'Contoh: X-IPA-6281',
                        controller: kodeKelasCtrl,
                        icon: Icons.qr_code_outlined,
                      ),
                    ] else ...[
                      if (guru.sekolah.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Sekolah saat ini: ${guru.sekolah}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      AppInput(
                        label: 'Sekolah ID (UUID)',
                        hint: 'Contoh: f0de24e9-e8b7-441c-9194-05ede36ba908',
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
                            formError =
                                'Nama sekolah dan kode kelas awal wajib diisi';
                          });
                          return;
                        }

                        if (isEdit && sekolahId.isEmpty) {
                          setModalState(() {
                            formError =
                                'Sekolah ID wajib diisi untuk memperbarui data';
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
                        final navigator = Navigator.of(sheetContext);
                        dynamic res;

                        if (isEdit) {
                          res = await AdminService.instance.updateGuru(
                            guru.id,
                            namaGuru: nama,
                            nim: nim,
                            sekolahId: sekolahId,
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
                          navigator.pop();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                res.message.isNotEmpty
                                    ? res.message
                                    : (isEdit
                                          ? 'Data guru berhasil diperbarui'
                                          : 'Guru berhasil ditambahkan'),
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

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keluar Akun',
      message: 'Anda yakin ingin keluar dari akun administrator?',
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
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _guruList
        : _guruList.where((g) {
            final q = _searchQuery.toLowerCase();
            return g.namaGuru.toLowerCase().contains(q) ||
                g.nim.toLowerCase().contains(q) ||
                g.sekolah.toLowerCase().contains(q) ||
                g.kelasList.any(
                  (k) =>
                      k.namaKelas.toLowerCase().contains(q) ||
                      k.kodeKelas.toLowerCase().contains(q),
                );
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Keluar Akun',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_manajemen_guru',
        onPressed: () => _showGuruFormModal(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Guru'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(isRefresh: true),
        child: Column(
          children: [
            // Search Bar & Filter Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppSearchBar(
                controller: _searchController,
                hint: 'Cari nama guru, NIM, sekolah, atau kelas...',
                onChanged: (v) {
                  setState(() => _searchQuery = v);
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0);
                  }
                  _loadData(isRefresh: true);
                },
              ),
            ),

            // Info Count & Pagination Status Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Menampilkan ${filtered.length} guru',
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

            // Content List
            Expanded(
              child: _isLoading && _guruList.isEmpty
                  ? const Center(
                      child: LoadingState(message: 'Memuat data guru...'),
                    )
                  : _guruList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.people_outline,
                          title: 'Belum ada data guru',
                          message:
                              _errorMessage ??
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
                          message:
                              'Tidak ada guru yang cocok dengan kriteria pencarian.',
                        ),
                      ],
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: filtered.length + (_isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index >= filtered.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        }
                        final g = filtered[index];
                        return AppCard(
                          onTap: () => _showGuruOptions(g),
                          onLongPress: () => _showGuruOptions(g),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppAvatar(
                                    name: g.namaGuru.isNotEmpty
                                        ? g.namaGuru
                                        : 'Guru',
                                    size: 44,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          g.namaGuru.isNotEmpty
                                              ? g.namaGuru
                                              : 'Tanpa Nama',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'NIM: ${g.nim.isNotEmpty ? g.nim : '-'}',
                                                style: const TextStyle(
                                                  fontSize: 11,
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
                                      g.sekolah.isNotEmpty
                                          ? g.sekolah
                                          : 'Sekolah belum diatur',
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
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        k.namaKelas.isNotEmpty
                                            ? k.namaKelas
                                            : k.kodeKelas,
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
