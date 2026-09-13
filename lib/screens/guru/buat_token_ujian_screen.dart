import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../../services/game_token_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class BuatTokenUjianScreen extends StatefulWidget {
  final Kelas kelas;
  final String? _kelasId;
  final String? _namaKelas;
  final int? _tingkat;

  const BuatTokenUjianScreen({
    super.key,
    required this.kelas,
    String? kelasId,
    String? namaKelas,
    int? tingkat,
  }) : _kelasId = kelasId,
       _namaKelas = namaKelas,
       _tingkat = tingkat;

  String get kelasId => _kelasId ?? kelas.kelasId;
  String get namaKelas => _namaKelas ?? kelas.namaKelas;
  int get tingkat => _tingkat ?? kelas.tingkat;

  @override
  State<BuatTokenUjianScreen> createState() => _BuatTokenUjianScreenState();
}

class _BuatTokenUjianScreenState extends State<BuatTokenUjianScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaSesiController;

  // Form states
  late int _selectedSemester;
  bool _isAcak = true;
  bool _isOffline = true;
  DateTime? _berlakuSampai;
  final List<String> _selectedMateriBabIds = const [];

  // Submit state
  bool _isSubmitting = false;

  /// Daftar semester yang diizinkan berdasarkan tingkat kelas
  /// - Kelas 10: 1 s/d 2
  /// - Kelas 11: 1 s/d 4
  /// - Kelas 12: 1 s/d 6
  List<int> get _allowedSemesters {
    final t = widget.tingkat;
    if (t == 12) {
      return const [1, 2, 3, 4, 5, 6];
    } else if (t == 11) {
      return const [1, 2, 3, 4];
    } else {
      return const [1, 2];
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedSemester = 1;
    _namaSesiController = TextEditingController(
      text: 'Ulangan Harian Geografi - ${widget.namaKelas}',
    );
    // Default berlaku sampai 7 hari ke depan
    _berlakuSampai = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _namaSesiController.dispose();
    super.dispose();
  }


  Future<void> _pickBerlakuSampai() async {
    final now = DateTime.now();
    final initialDate = _berlakuSampai ?? now.add(const Duration(days: 7));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? initialDate : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'PILIH TANGGAL BERLAKU TOKEN',
      confirmText: 'LANJUT',
      cancelText: 'BATAL',
    );

    if (pickedDate == null || !mounted) return;

    final initialTime = TimeOfDay.fromDateTime(_berlakuSampai ?? now);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'PILIH WAKTU BERLAKU TOKEN',
      confirmText: 'SIMPAN',
      cancelText: 'BATAL',
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _berlakuSampai = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  String _formatDateTime(DateTime dt) {
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final d = dt.day.toString().padLeft(2, '0');
    final m = bulan[dt.month - 1];
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d $m $y, $h:$min WIB';
  }

  Future<void> _handleSubmit() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await GameTokenService.instance.createGameToken(
        namaSesi: _namaSesiController.text.trim(),
        kelasId: widget.kelasId,
        semester: _selectedSemester,
        materiBabIds: _selectedMateriBabIds,
        acak: _isAcak,
        izinkanOffline: _isOffline,
        berlakuSampai: _berlakuSampai,
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (res.success && res.data != null) {
        final kodeToken = res.data!['kode_token']?.toString() ?? '-';
        _showSuccessDialog(kodeToken);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.message.isNotEmpty
                  ? res.message
                  : 'Gagal membuat token ujian',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(String kodeToken) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Token Berhasil Dibuat!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Bagikan kode token ini kepada siswa kelas ${widget.namaKelas} untuk memulai ujian.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Token display card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'KODE TOKEN UJIAN',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        kodeToken,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol "Salin Kode"
                AppButton(
                  label: 'Salin Kode Token',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: kodeToken));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Kode token berhasil disalin ke clipboard!',
                        ),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Tombol "Selesai" (pop modal dan kembali ke halaman sebelumnya)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      foregroundColor: AppColors.text,
                    ),
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      'Selesai',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Token Ujian Baru')),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: AppButton(
            label: 'Buat Token',
            isLoading: _isSubmitting,
            onPressed: _handleSubmit,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _namaSesiController,
                    decoration: InputDecoration(
                      labelText: 'Nama Sesi / Ujian',
                      hintText: 'Ulangan Harian Geografi - ${widget.namaKelas}',
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama sesi / ujian tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Divider(),

                  // Switch: Acak Urutan Soal
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Acak Urutan Soal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    subtitle: const Text(
                      'Urutan soal akan diacak otomatis untuk setiap siswa',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _isAcak,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isAcak = val),
                  ),
                  const Divider(),

                  // Switch: Izinkan Mode Offline
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Izinkan Mode Offline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    subtitle: const Text(
                      'Siswa dapat mengunduh paket soal dan bermain tanpa internet stabil',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _isOffline,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isOffline = val),
                  ),
                  const Divider(),

                  // Date & Time Picker: Berlaku Sampai
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Berlaku Sampai (Opsional)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            if (_berlakuSampai != null)
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () =>
                                    setState(() => _berlakuSampai = null),
                                child: const Text(
                                  'Tanpa Batas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickBerlakuSampai,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
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
                                const Icon(
                                  Icons.event_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _berlakuSampai != null
                                        ? _formatDateTime(_berlakuSampai!)
                                        : 'Tidak ada batas waktu (Aktif selamanya)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _berlakuSampai != null
                                          ? AppColors.text
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Pilih Materi & Bab
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Soal Semester',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _selectedSemester,
                    decoration: InputDecoration(
                      labelText: 'Semester',
                      prefixIcon: const Icon(Icons.calendar_view_day_outlined),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    items: _allowedSemesters.map((s) {
                      return DropdownMenuItem<int>(
                        value: s,
                        child: Text(
                          'Semester $s (Kelas ${widget.tingkat})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null && val != _selectedSemester) {
                        setState(() {
                          _selectedSemester = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
