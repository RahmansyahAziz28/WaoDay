import 'package:flutter/material.dart';

import '../../models/sekolah.dart';
import '../../services/admin_sekolah_service.dart';
import '../../services/admin_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

/// Screen for Managing Schools (CRUD Sekolah) for SuperAdmin role.
/// Fully connected to live API: GET /api/sekolah?page=1&limit=20, POST, PUT, DELETE.
class ManajemenSekolahScreen extends StatefulWidget {
  const ManajemenSekolahScreen({
    super.key,
    this.onSelectSekolahForAdmin,
  });

  final ValueChanged<Sekolah>? onSelectSekolahForAdmin;

  @override
  State<ManajemenSekolahScreen> createState() => _ManajemenSekolahScreenState();
}

class _ManajemenSekolahScreenState extends State<ManajemenSekolahScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Sekolah> _sekolahList = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';
  String? _errorMessage;

  // Pagination
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
      final res = await AdminService.instance.getSekolahPaginated(
        page: 1,
        limit: _limit > 0 ? _limit : 20,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (res.success && res.data != null) {
          _sekolahList = List.from(res.data!.data);
          _totalCount = res.data!.count;
          _currentPage = res.data!.page;
          _limit = res.data!.limit > 0 ? res.data!.limit : 20;
          _hasMore = _sekolahList.length < _totalCount && res.data!.data.isNotEmpty;
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

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final res = await AdminService.instance.getSekolahPaginated(
        page: nextPage,
        limit: _limit > 0 ? _limit : 20,
      );

      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
        if (res.success && res.data != null) {
          final newItems = res.data!.data;
          _sekolahList.addAll(newItems);
          _currentPage = res.data!.page;
          _totalCount = res.data!.count;
          _hasMore = _sekolahList.length < _totalCount && newItems.isNotEmpty;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  List<Sekolah> get _filteredList {
    if (_searchQuery.isEmpty) return _sekolahList;
    final q = _searchQuery.toLowerCase();
    return _sekolahList.where((s) {
      final nama = s.nama.toLowerCase();
      final alamat = (s.alamat ?? '').toLowerCase();
      return nama.contains(q) || alamat.contains(q);
    }).toList();
  }

  // ── FORM DIALOGS ─────────────────────────────────────────────────────────────

  Future<void> _showAddSekolahDialog() async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final alamatController = TextEditingController();
    bool isSubmitting = false;
    String? submitError;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text('Tambah Sekolah'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (submitError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  submitError!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Sekolah *',
                          hintText: 'Misal: SMA Negeri 1 Jakarta',
                          prefixIcon: Icon(Icons.domain_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama sekolah wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: alamatController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Sekolah *',
                          hintText: 'Misal: Jl. Merdeka No. 1, Jakarta',
                          prefixIcon: Icon(Icons.location_on_rounded),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Alamat sekolah wajib diisi';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isSubmitting = true;
                            submitError = null;
                          });

                          final res = await AdminService.instance.createSekolah(
                            namaSekolah: namaController.text.trim(),
                            alamat: alamatController.text.trim(),
                          );

                          if (!dialogContext.mounted) return;

                          if (res.success) {
                            Navigator.of(dialogContext).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res.message),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              _loadData(isRefresh: true);
                            }
                          } else {
                            setDialogState(() {
                              isSubmitting = false;
                              submitError = res.message;
                            });
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    namaController.dispose();
    alamatController.dispose();
  }

  Future<void> _showEditSekolahDialog(Sekolah sekolah) async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: sekolah.nama);
    final alamatController = TextEditingController(text: sekolah.alamat ?? '');
    bool isSubmitting = false;
    String? submitError;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text('Edit Sekolah'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (submitError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  submitError!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Sekolah *',
                          prefixIcon: Icon(Icons.domain_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama sekolah wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: alamatController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Sekolah *',
                          prefixIcon: Icon(Icons.location_on_rounded),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Alamat sekolah wajib diisi';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isSubmitting = true;
                            submitError = null;
                          });

                          final res = await AdminService.instance.updateSekolah(
                            sekolah.id,
                            namaSekolah: namaController.text.trim(),
                            alamat: alamatController.text.trim(),
                          );

                          if (!dialogContext.mounted) return;

                          if (res.success) {
                            Navigator.of(dialogContext).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res.message),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              _loadData(isRefresh: true);
                            }
                          } else {
                            setDialogState(() {
                              isSubmitting = false;
                              submitError = res.message;
                            });
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Perbarui'),
                ),
              ],
            );
          },
        );
      },
    );

    namaController.dispose();
    alamatController.dispose();
  }

  Future<void> _handleDeleteSekolah(Sekolah sekolah) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Sekolah?',
      message: 'Apakah Anda yakin ingin menghapus "${sekolah.nama}"? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus Sekolah',
      cancelLabel: 'Batal',
      isDangerous: true,
    );

    if (!confirmed || !mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Menghapus data sekolah...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    final res = await AdminService.instance.deleteSekolah(sekolah.id);

    if (!mounted) return;

    if (res.success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData(isRefresh: true);
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadData(isRefresh: true),
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Top Action Bar & Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Cari sekolah atau alamat...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _showAddSekolahDialog,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Tambah'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 46),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Total: $_totalCount Sekolah',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${filtered.length} hasil ditemukan)',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Content
            if (_isLoading && _sekolahList.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: LoadingState(message: 'Memuat data sekolah...'),
                ),
              )
            else if (_errorMessage != null && _sekolahList.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 54, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _loadData(isRefresh: true),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: EmptyState(
                    title: _searchQuery.isNotEmpty ? 'Sekolah Tidak Ditemukan' : 'Belum Ada Data Sekolah',
                    message: _searchQuery.isNotEmpty
                        ? 'Coba kata kunci pencarian yang lain.'
                        : 'Klik tombol "Tambah" di atas untuk mendaftarkan sekolah pertama.',
                    icon: Icons.school_outlined,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == filtered.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: _isLoadingMore
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.2),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }

                      final sekolah = filtered[index];
                      return _buildSekolahCard(sekolah);
                    },
                    childCount: filtered.length + (_hasMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSekolahCard(Sekolah sekolah) {
    // Check how many admins are registered in this school
    final adminCount = AdminSekolahService.instance.allAdmins
        .where((a) => a.sekolahId == sekolah.id)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sekolah.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              sekolah.alamat?.isNotEmpty == true
                                  ? sekolah.alamat!
                                  : 'Alamat belum diatur',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditSekolahDialog(sekolah);
                    } else if (value == 'delete') {
                      _handleDeleteSekolah(sekolah);
                    } else if (value == 'admin') {
                      widget.onSelectSekolahForAdmin?.call(sekolah);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                          SizedBox(width: 10),
                          Text('Edit Sekolah'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'admin',
                      child: Row(
                        children: [
                          Icon(Icons.manage_accounts_outlined, size: 18, color: AppColors.secondary),
                          SizedBox(width: 10),
                          Text('Kelola Admin'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                          SizedBox(width: 10),
                          Text('Hapus Sekolah', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Admin count badge
                InkWell(
                  onTap: () => widget.onSelectSekolahForAdmin?.call(sekolah),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 15,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$adminCount Admin Terdaftar',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Quick actions
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 19, color: AppColors.primary),
                      tooltip: 'Edit Sekolah',
                      onPressed: () => _showEditSekolahDialog(sekolah),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 19, color: AppColors.error),
                      tooltip: 'Hapus Sekolah',
                      onPressed: () => _handleDeleteSekolah(sekolah),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
