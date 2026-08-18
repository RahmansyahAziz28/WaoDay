import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _nomorController = TextEditingController();
  final _kelasController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _sekolah;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _success = false;

  final Map<String, String> _errors = {};

  @override
  void dispose() {
    _namaController.dispose();
    _nomorController.dispose();
    _kelasController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    _errors.clear();
    if (_namaController.text.trim().isEmpty) {
      _errors['nama'] = 'Nama wajib diisi';
    }
    if (_nomorController.text.trim().isEmpty) {
      _errors['nomor'] = 'NIM wajib diisi';
    }
    if (_sekolah == null) {
      _errors['sekolah'] = 'Pilih sekolah';
    }
    if (_kelasController.text.trim().isEmpty) {
      _errors['kelas'] = 'Kode kelas wajib diisi';
    }
    if (_passwordController.text.length < 6) {
      _errors['password'] = 'Minimal 6 karakter';
    }
    if (_confirmController.text != _passwordController.text) {
      _errors['confirm'] = 'Kata sandi tidak cocok';
    }
    return _errors.isEmpty;
  }

  Future<void> _handleRegister() async {
    final valid = _validate();
    setState(() {});
    if (!valid) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Akun Guru')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check_circle, color: AppColors.success, size: 44),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pendaftaran Berhasil',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Akun Guru Anda telah dibuat. Silakan masuk menggunakan akun yang baru saja Anda daftarkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                AppButton(label: 'Ke Halaman Masuk', onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Guru')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat akun guru baru',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
              ),
              const SizedBox(height: 6),
              const Text(
                'Lengkapi data di bawah untuk mendaftar sebagai guru',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              AppInput(
                label: 'Nama Lengkap',
                controller: _namaController,
                hint: 'Masukkan nama lengkap beserta gelar',
                icon: Icons.person_outline,
                errorText: _errors['nama'],
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'NIM / NIP',
                controller: _nomorController,
                hint: 'Nomor Induk Guru / Pegawai',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                errorText: _errors['nomor'],
              ),
              const SizedBox(height: 16),
              Text('Sekolah', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _sekolah,
                decoration: InputDecoration(
                  hintText: 'Pilih sekolah',
                  prefixIcon: const Icon(Icons.apartment_outlined, size: 22),
                  errorText: _errors['sekolah'],
                ),
                items: AppData.instance.sekolahList
                    .map((s) => DropdownMenuItem(value: s.nama, child: Text(s.nama)))
                    .toList(),
                onChanged: (v) => setState(() => _sekolah = v),
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Kode Kelas',
                controller: _kelasController,
                hint: 'Contoh: XIPA1',
                icon: Icons.class_outlined,
                errorText: _errors['kelas'],
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Kata Sandi',
                controller: _passwordController,
                hint: 'Minimal 6 karakter',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                errorText: _errors['password'],
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Konfirmasi Kata Sandi',
                controller: _confirmController,
                hint: 'Ulangi kata sandi',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                errorText: _errors['confirm'],
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Daftar', isLoading: _isLoading, onPressed: _handleRegister),
            ],
          ),
        ),
      ),
    );
  }
}
