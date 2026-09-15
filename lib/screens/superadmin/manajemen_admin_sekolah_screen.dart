import 'package:flutter/material.dart';

import '../../models/admin_sekolah.dart';
import '../../models/sekolah.dart';
import '../../services/admin_sekolah_service.dart';
import '../../services/admin_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

/// Screen for Managing School Administrators (Admin per Sekolah) for SuperAdmin role.
/// Fully interactive UI with CRUD forms, school filter, and local state management.
/// Ready to connect to backend endpoints once API is available.
class ManajemenAdminSekolahScreen extends StatefulWidget {
  const ManajemenAdminSekolahScreen({super.key, this.initialSekolahId});

  final String? initialSekolahId;

  @override
  State<ManajemenAdminSekolahScreen> createState() =>
      _ManajemenAdminSekolahScreenState();
}

class _ManajemenAdminSekolahScreenState
    extends State<ManajemenAdminSekolahScreen> {
  final _searchController = TextEditingController();
  final _adminService = AdminSekolahService.instance;

  List<AdminSekolah> _admins = [];
  List<Sekolah> _sekolahList = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedSekolahId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedSekolahId = widget.initialSekolahId;
    _adminService.addListener(_onAdminServiceChanged);
    _loadSekolahList();
    _loadAdmins();
  }

  @override
  void didUpdateWidget(covariant ManajemenAdminSekolahScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSekolahId != oldWidget.initialSekolahId &&
        widget.initialSekolahId != null) {
      setState(() {
        _selectedSekolahId = widget.initialSekolahId;
      });
      _loadAdmins();
    }
  }

  @override
  void dispose() {
    _adminService.removeListener(_onAdminServiceChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onAdminServiceChanged() {
    if (mounted) {
      _loadAdmins();
    }
  }

  Future<void> _loadSekolahList() async {
    try {
      final res = await AdminService.instance.getSekolahList();
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() {
          _sekolahList = res.data!;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadAdmins() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await _adminService.getAdminList(
      sekolahId: _selectedSekolahId,
      search: _searchQuery,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res.success && res.data != null) {
        _admins = res.data!;
      } else {
        _errorMessage = res.message;
      }
    });
  }

  List<AdminSekolah> get _filteredAdmins {
    if (_searchQuery.isEmpty) return _admins;
    final q = _searchQuery.toLowerCase();
    return _admins.where((a) {
      return a.nama.toLowerCase().contains(q) ||
          a.email.toLowerCase().contains(q) ||
          a.sekolahNama.toLowerCase().contains(q);
    }).toList();
  }

  // ── DIALOG FORM TAMBAH ADMIN ───────────────────────────────────────────────

  Future<void> _showAddAdminDialog() async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final teleponController = TextEditingController();
    String? selectedSekolahId =
        _selectedSekolahId != null && _selectedSekolahId != 'all'
        ? _selectedSekolahId
        : (_sekolahList.isNotEmpty ? _sekolahList.first.id : null);
    bool obscurePassword = true;
    bool isSubmitting = false;
    String? submitError;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Tambah Admin Sekolah',
                            style: TextStyle(
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
                      if (submitError != null) ...[
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
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  submitError!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Pilih Sekolah Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedSekolahId,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Sekolah Penugasan *',
                          prefixIcon: Icon(Icons.school_rounded),
                        ),
                        items: _sekolahList.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.id,
                            child: Text(
                              s.nama,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Silakan pilih sekolah';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setDialogState(() => selectedSekolahId = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Nama
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap Admin *',
                          hintText: 'Misal: Ahmad Fauzi, S.Kom',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama admin wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Admin (Opsional)',
                          hintText: 'admin@sekolah.sch.id',
                          helperText: 'Akan di-generate otomatis jika kosong',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v != null &&
                              v.trim().isNotEmpty &&
                              !v.contains('@')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Awal (Opsional)',
                          helperText: 'Akan di-generate otomatis jika kosong',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Telepon
                      TextFormField(
                        controller: teleponController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'No. Telepon / WhatsApp (Opsional)',
                          hintText: '0812xxxxxxxx',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Batal',
                              variant: AppButtonVariant.outlined,
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.of(sheetContext).pop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Simpan',
                              isLoading: isSubmitting,
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final school = _sekolahList.firstWhere(
                                        (s) => s.id == selectedSekolahId,
                                        orElse: () => Sekolah(
                                          id: selectedSekolahId ?? '',
                                          nama: 'Sekolah Terpilih',
                                        ),
                                      );

                                      setDialogState(() {
                                        isSubmitting = true;
                                        submitError = null;
                                      });

                                      final res = await _adminService.createAdmin(
                                        nama: namaController.text.trim(),
                                        email: emailController.text.trim(),
                                        password: passwordController.text,
                                        sekolahId: school.id,
                                        sekolahNama: school.nama,
                                        telepon: teleponController.text.trim(),
                                      );

                                      if (!sheetContext.mounted) return;

                                      if (res.success) {
                                        Navigator.of(sheetContext).pop();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(res.message),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                          _loadAdmins();
                                        }
                                      } else {
                                        setDialogState(() {
                                          isSubmitting = false;
                                          submitError = res.message;
                                        });
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    teleponController.dispose();
  }

  // ── DIALOG FORM EDIT ADMIN ─────────────────────────────────────────────────

  Future<void> _showEditAdminDialog(AdminSekolah admin) async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: admin.nama);
    final emailController = TextEditingController(text: admin.email);
    final passwordController = TextEditingController();
    final teleponController = TextEditingController(text: admin.telepon ?? '');
    String? selectedSekolahId = admin.sekolahId;
    bool obscurePassword = true;
    bool isActive = admin.isActive;
    bool isSubmitting = false;
    String? submitError;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.manage_accounts_rounded,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Edit Admin Sekolah',
                            style: TextStyle(
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
                      if (submitError != null) ...[
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
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  submitError!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Pilih Sekolah Dropdown
                      DropdownButtonFormField<String>(
                        initialValue:
                            _sekolahList.any((s) => s.id == selectedSekolahId)
                                ? selectedSekolahId
                                : null,
                        decoration: const InputDecoration(
                          labelText: 'Sekolah Penugasan *',
                          prefixIcon: Icon(Icons.school_rounded),
                        ),
                        items: _sekolahList.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.id,
                            child: Text(
                              s.nama,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Silakan pilih sekolah';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setDialogState(() => selectedSekolahId = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Nama
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap Admin *',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama admin wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Admin *',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!v.contains('@')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password Baru (Opsional)
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Baru (Opsional)',
                          helperText:
                              'Kosongkan jika tidak ingin mengubah sandi',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Telepon
                      TextFormField(
                        controller: teleponController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'No. Telepon / WhatsApp',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Status Aktif Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Status Akun Aktif',
                          style: TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          isActive
                              ? 'Admin dapat login dan mengelola sekolah'
                              : 'Akses login ditangguhkan sementara',
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: isActive,
                        activeThumbColor: AppColors.success,
                        onChanged: (val) {
                          setDialogState(() => isActive = val);
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Batal',
                              variant: AppButtonVariant.outlined,
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.of(sheetContext).pop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Perbarui',
                              isLoading: isSubmitting,
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final school = _sekolahList.firstWhere(
                                        (s) => s.id == selectedSekolahId,
                                        orElse: () => Sekolah(
                                          id: selectedSekolahId ??
                                              admin.sekolahId,
                                          nama: admin.sekolahNama,
                                        ),
                                      );

                                      setDialogState(() {
                                        isSubmitting = true;
                                        submitError = null;
                                      });

                                      final res = await _adminService
                                          .updateAdmin(
                                            admin.id,
                                            nama: namaController.text.trim(),
                                            email: emailController.text.trim(),
                                            password: passwordController
                                                    .text
                                                    .isNotEmpty
                                                ? passwordController.text
                                                : null,
                                            sekolahId: school.id,
                                            sekolahNama: school.nama,
                                            telepon:
                                                teleponController.text.trim(),
                                            isActive: isActive,
                                          );

                                      if (!sheetContext.mounted) return;

                                      if (res.success) {
                                        Navigator.of(sheetContext).pop();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                SnackBar(
                                                  content: Text(res.message),
                                                  backgroundColor:
                                                      AppColors.success,
                                                ),
                                              );
                                          _loadAdmins();
                                        }
                                      } else {
                                        setDialogState(() {
                                          isSubmitting = false;
                                          submitError = res.message;
                                        });
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    teleponController.dispose();
  }

  Future<void> _handleDeleteAdmin(AdminSekolah admin) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Admin Sekolah?',
      message:
          'Apakah Anda yakin ingin menghapus hak akses admin "${admin.nama}" untuk ${admin.sekolahNama}?',
      confirmLabel: 'Hapus Admin',
      cancelLabel: 'Batal',
      isDangerous: true,
    );

    if (!confirmed || !mounted) return;

    final res = await _adminService.deleteAdmin(admin.id);

    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.success,
        ),
      );
      _loadAdmins();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admins = _filteredAdmins;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadSekolahList();
          await _loadAdmins();
        },
        color: AppColors.secondary,
        child: CustomScrollView(
          slivers: [
            // Top Filter & Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedSekolahId ?? 'all',
                            isExpanded: true,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(
                                Icons.filter_list_rounded,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: 'all',
                                child: Text('Semua Sekolah'),
                              ),
                              ..._sekolahList.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s.id,
                                  child: Text(
                                    s.nama,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedSekolahId = (val == 'all')
                                    ? null
                                    : val;
                              });
                              _loadAdmins();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _showAddAdminDialog,
                          icon: const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 18,
                          ),
                          label: const Text('Tambah'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search textfield
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nama admin, email, atau sekolah...',
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                          horizontal: 16,
                        ),
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
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Text(
                          'Menampilkan ${admins.length} Admin',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_selectedSekolahId != null) ...[
                          const SizedBox(width: 8),
                          ActionChip(
                            label: const Text(
                              'Reset Filter Sekolah',
                              style: TextStyle(fontSize: 11),
                            ),
                            avatar: const Icon(Icons.close_rounded, size: 14),
                            onPressed: () {
                              setState(() => _selectedSekolahId = null);
                              _loadAdmins();
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Admin List
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: LoadingState(message: 'Memuat data admin...'),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 54,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadAdmins,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (admins.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: EmptyState(
                    title: _searchQuery.isNotEmpty
                        ? 'Admin Tidak Ditemukan'
                        : 'Belum Ada Admin Terdaftar',
                    message: _searchQuery.isNotEmpty
                        ? 'Coba gunakan kata kunci pencarian yang lain.'
                        : 'Klik tombol "Tambah" di atas untuk menambahkan admin sekolah.',
                    icon: Icons.admin_panel_settings_outlined,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final admin = admins[index];
                    return _buildAdminCard(admin);
                  }, childCount: admins.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(AdminSekolah admin) {
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
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: admin.isActive
                      ? AppColors.secondary.withValues(alpha: 0.12)
                      : Colors.grey.shade200,
                  child: Text(
                    admin.nama.isNotEmpty ? admin.nama[0].toUpperCase() : 'A',
                    style: TextStyle(
                      color: admin.isActive
                          ? AppColors.secondary
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              admin.nama,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          if (admin.isSuperAdmin) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Super Admin',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: admin.isActive
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              admin.isActive ? 'Aktif' : 'Nonaktif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: admin.isActive
                                    ? AppColors.success
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              admin.email,
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
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditAdminDialog(admin);
                    } else if (value == 'delete') {
                      _handleDeleteAdmin(admin);
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
                          SizedBox(width: 10),
                          Text('Edit Admin'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Hapus Admin',
                            style: TextStyle(color: AppColors.error),
                          ),
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

            // School association & Phone
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          admin.sekolahNama,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (admin.telepon != null && admin.telepon!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        admin.telepon!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
