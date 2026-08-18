import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const routeName = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final value = _emailController.text.trim();
    setState(() {
      _error = value.isEmpty ? 'Wajib diisi' : (!value.contains('@') ? 'Masukkan email yang valid' : null);
    });
    if (_error != null) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Kata Sandi')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          alignment: Alignment.center,
          child: const Icon(Icons.lock_reset_outlined, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 20),
        const Text(
          'Reset Kata Sandi',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        const SizedBox(height: 6),
        const Text(
          'Masukkan email yang terdaftar. Kami akan mengirimkan instruksi untuk mengatur ulang kata sandi Anda.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        AppInput(
          label: 'Email',
          controller: _emailController,
          hint: 'nama@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: _error,
        ),
        const SizedBox(height: 24),
        AppButton(label: 'Kirim Instruksi', isLoading: _isLoading, onPressed: _handleSubmit),
      ],
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 42),
          ),
          const SizedBox(height: 20),
          const Text(
            'Instruksi Terkirim',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Kami telah mengirimkan instruksi reset kata sandi ke ${_emailController.text.trim()}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          AppButton(label: 'Kembali ke Halaman Masuk', onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
