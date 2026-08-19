import 'package:flutter/material.dart';

import '../../models/sekolah.dart';
import '../../services/admin_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class ManajemenSekolahScreen extends StatefulWidget {
  const ManajemenSekolahScreen({super.key});

  @override
  State<ManajemenSekolahScreen> createState() => _ManajemenSekolahScreenState();
}

class _ManajemenSekolahScreenState extends State<ManajemenSekolahScreen> {
  final _searchController = TextEditingController();
  List<Sekolah> _sekolahList = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSekolah();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSekolah() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AdminService.instance.getSekolahList();
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _sekolahList = res.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = res.message;
        _isLoading = false;
      });
    }
  }

  void _showSekolahOptions(Sekolah sekolah) {
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.apartment_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sekolah.namaSekolah,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          if (sekolah.alamat != null && sekolah.alamat!.isNotEmpty)
                            Text(
                              sekolah.alamat!,
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
                title: const Text('Edit Sekolah'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showSekolahFormModal(sekolah: sekolah);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Hapus Sekolah', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _handleDeleteSekolah(sekolah);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteSekolah(Sekolah sekolah) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Sekolah',
      message:
          'Yakin ingin menghapus "${sekolah.namaSekolah}"? Tindakan ini dapat mempengaruhi data guru dan kelas terkait.',
    );
    if (!confirmed || !mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final res = await AdminService.instance.deleteSekolah(sekolah.id);
    if (!mounted) return;

    if (res.success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(res.message.isNotEmpty ? res.message : 'Sekolah berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadSekolah();
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSekolahFormModal({Sekolah? sekolah}) {
    final isEdit = sekolah != null;
    final namaCtrl = TextEditingController(text: isEdit ? sekolah.namaSekolah : '');
    final alamatCtrl = TextEditingController(text: isEdit ? (sekolah.alamat ?? '') : '');

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
                          isEdit ? 'Edit Sekolah' : 'Tambah Sekolah Baru',
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
                      label: 'Nama Sekolah',
                      hint: 'Contoh: SMA Negeri 1 Jakarta',
                      controller: namaCtrl,
                      icon: Icons.apartment_outlined,
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      label: 'Alamat',
                      hint: 'Contoh: Jl. Merdeka No. 1, Jakarta',
                      controller: alamatCtrl,
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: isEdit ? 'Simpan Perubahan' : 'Tambah Sekolah',
                      isLoading: isSubmitting,
                      onPressed: () async {
                        final nama = namaCtrl.text.trim();
                        final alamat = alamatCtrl.text.trim();

                        if (nama.isEmpty) {
                          setModalState(() {
                            formError = 'Nama sekolah wajib diisi';
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
                          res = await AdminService.instance.updateSekolah(
                            sekolah.id,
                            namaSekolah: nama,
                            alamat: alamat,
                          );
                        } else {
                          res = await AdminService.instance.createSekolah(
                            namaSekolah: nama,
                            alamat: alamat,
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
                                    : (isEdit ? 'Sekolah berhasil diperbarui' : 'Sekolah berhasil ditambahkan'),
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          _loadSekolah();
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
        ? _sekolahList
        : _sekolahList.where((s) {
            final q = _searchQuery.toLowerCase();
            return s.namaSekolah.toLowerCase().contains(q) ||
                (s.alamat?.toLowerCase().contains(q) ?? false);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Sekolah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _loadSekolah,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSekolahFormModal(),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Tambah Sekolah'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadSekolah,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppSearchBar(
                controller: _searchController,
                hint: 'Cari nama atau alamat sekolah...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            Expanded(
              child: _isLoading && _sekolahList.isEmpty
                  ? const Center(child: LoadingState(message: 'Memuat data sekolah...'))
                  : _sekolahList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            EmptyState(
                              icon: Icons.apartment_outlined,
                              title: 'Belum ada data sekolah',
                              message: _errorMessage ??
                                  'Tekan tombol Tambah Sekolah untuk mendaftarkan sekolah baru ke sistem.',
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
                                  message: 'Tidak ada sekolah yang cocok dengan pencarian.',
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final s = filtered[index];
                                return AppCard(
                                  onTap: () => _showSekolahOptions(s),
                                  child: InkWell(
                                    onLongPress: () => _showSekolahOptions(s),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                            Icons.apartment_rounded,
                                            color: AppColors.primary,
                                            size: 26,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s.namaSekolah,
                                                style: const TextStyle(
                                                  fontSize: 15,
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
                                                    size: 15,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      (s.alamat != null && s.alamat!.isNotEmpty)
                                                          ? s.alamat!
                                                          : 'Alamat belum diatur',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.textSecondary,
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
                                          onPressed: () => _showSekolahOptions(s),
                                        ),
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
