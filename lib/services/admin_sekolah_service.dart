import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../data/dummy_data.dart';
import '../models/admin_sekolah.dart';
import '../models/auth_user.dart';
import 'api_client.dart';
import 'auth_service.dart';

/// Service for managing School Administrators (Admin per Sekolah).
/// Communicates with backend endpoints:
/// - POST /api/admin (Tambah admin baru)
/// - PUT  /api/admin/{id} (Update data admin)
/// - GET  /api/admin (Ambil semua admin, filter per sekolah/search)
/// - DELETE /api/admin/{id} (Hapus admin)
class AdminSekolahService extends ChangeNotifier {
  AdminSekolahService._internal() {
    _seedInitialData();
  }

  static final AdminSekolahService instance = AdminSekolahService._internal();

  final List<AdminSekolah> _admins = [];

  List<AdminSekolah> get allAdmins => List.unmodifiable(_admins);

  Future<String?> _getToken() async {
    try {
      return await AuthService.instance.getToken() ?? AppData.instance.token;
    } catch (_) {
      return AppData.instance.token;
    }
  }

  void _seedInitialData() {
    _admins.addAll([
      const AdminSekolah(
        id: 'adm-001',
        nama: 'Ahmad Fauzi, S.Kom',
        email: 'admin.sman1@sekolah.sch.id',
        sekolahId: '525f2b9e-de36-4b68-8409-2cbf4866a8bc',
        sekolahNama: 'SMA Negeri 1 Jakarta',
        telepon: '081234567890',
        isActive: true,
        createdAt: '2026-08-16T14:00:00.000Z',
      ),
      const AdminSekolah(
        id: 'adm-002',
        nama: 'Dewi Sartika, M.Pd',
        email: 'admin.sman1indo@sekolah.sch.id',
        sekolahId: 'f0de24e9-e8b7-441c-9194-05ede36ba908',
        sekolahNama: 'SMA Negeri 1 Indonesia 4860',
        telepon: '081298765432',
        isActive: true,
        createdAt: '2026-08-17T09:30:00.000Z',
      ),
      const AdminSekolah(
        id: 'adm-003',
        nama: 'Rian Hidayat, S.T',
        email: 'admin.sman6226@sekolah.sch.id',
        sekolahId: '6e0ea52c-4b5a-4049-bcf3-be7872475ed3',
        sekolahNama: 'SMA Negeri 1 Indonesia 6226',
        telepon: '085712349876',
        isActive: false,
        createdAt: '2026-08-18T11:15:00.000Z',
      ),
    ]);
  }

  /// GET /api/admin?sekolah_id=...&search=...&page=...&limit=...
  /// Ambil semua admin sekolah dengan filter opsional.
  Future<ApiResponse<List<AdminSekolah>>> getAdminList({
    String? sekolahId,
    String? search,
    int? page,
    int? limit,
  }) async {
    final token = await _getToken();

    // Fallback in-memory jika belum autentikasi (misal di unit test)
    if (token == null || token.isEmpty) {
      List<AdminSekolah> filtered = List.from(_admins);
      if (sekolahId != null && sekolahId.isNotEmpty && sekolahId != 'all') {
        filtered = filtered.where((a) => a.sekolahId == sekolahId).toList();
      }
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim().toLowerCase();
        filtered = filtered.where((a) {
          return a.nama.toLowerCase().contains(q) ||
              a.email.toLowerCase().contains(q) ||
              a.sekolahNama.toLowerCase().contains(q);
        }).toList();
      }
      return ApiResponse<List<AdminSekolah>>(
        success: true,
        message: 'Berhasil memuat daftar admin (offline)',
        data: filtered,
      );
    }

    try {
      final uri = ApiConfig.adminQueryUri(
        sekolahId: sekolahId,
        search: search,
        page: page,
        limit: limit,
      );

      final response = await ApiClient.instance.get(uri, token: token);

      if (response.statusCode == 401) {
        return const ApiResponse<List<AdminSekolah>>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      Map<String, dynamic> responseData = {};
      try {
        if (response.body.trim().isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            responseData = decoded;
          }
        }
      } catch (_) {}

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rawData = responseData['data'];
        List<AdminSekolah> list = [];

        if (rawData is List) {
          list = rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => AdminSekolah.fromJson(e))
              .toList();
        } else if (rawData is Map<String, dynamic> && rawData['data'] is List) {
          list = (rawData['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => AdminSekolah.fromJson(e))
              .toList();
        }

        if (sekolahId == null || sekolahId == 'all') {
          _admins.clear();
          _admins.addAll(list);
          notifyListeners();
        }

        return ApiResponse<List<AdminSekolah>>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat daftar admin',
          data: list,
        );
      } else {
        return ApiResponse<List<AdminSekolah>>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat daftar admin (${response.statusCode})',
        );
      }
    } on SocketException {
      return const ApiResponse<List<AdminSekolah>>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<List<AdminSekolah>>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error getAdminList: $e');
      return ApiResponse<List<AdminSekolah>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST /api/admin
  /// Menambahkan admin baru untuk sekolah tertentu (maks 2 admin/sekolah).
  /// Body: { "nama_admin": "...", "sekolah_id": "...", "email": "...", "password": "..." }
  Future<ApiResponse<AdminSekolah>> createAdmin({
    String? nama,
    String? namaAdmin,
    required String sekolahId,
    String? email,
    String? password,
    String? sekolahNama,
    String? telepon,
  }) async {
    final effectiveNama = (namaAdmin ?? nama ?? '').trim();
    final token = await _getToken();

    // Fallback in-memory jika belum autentikasi
    if (token == null || token.isEmpty) {
      final emailClean = (email ?? '').trim().toLowerCase();
      if (emailClean.isNotEmpty) {
        final emailExists = _admins.any((a) => a.email.toLowerCase() == emailClean);
        if (emailExists) {
          return const ApiResponse<AdminSekolah>(
            success: false,
            message: 'Email sudah terdaftar untuk admin lain.',
          );
        }
      }

      final newAdmin = AdminSekolah(
        id: 'adm-${DateTime.now().millisecondsSinceEpoch}',
        nama: effectiveNama,
        email: emailClean,
        sekolahId: sekolahId,
        sekolahNama: sekolahNama ?? '',
        telepon: telepon?.trim().isEmpty ?? true ? null : telepon!.trim(),
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      _admins.insert(0, newAdmin);
      notifyListeners();

      return ApiResponse<AdminSekolah>(
        success: true,
        message: 'Admin per sekolah berhasil ditambahkan',
        data: newAdmin,
      );
    }

    try {
      final bodyMap = <String, dynamic>{
        'nama_admin': effectiveNama,
        'sekolah_id': sekolahId,
      };

      if (email != null && email.trim().isNotEmpty) {
        bodyMap['email'] = email.trim();
      }
      if (password != null && password.isNotEmpty) {
        bodyMap['password'] = password;
      }

      final response = await ApiClient.instance.post(
        ApiConfig.adminUri,
        token: token,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 401) {
        return const ApiResponse<AdminSekolah>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      Map<String, dynamic> responseData = {};
      try {
        if (response.body.trim().isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            responseData = decoded;
          }
        }
      } catch (_) {}

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final dataMap = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : <String, dynamic>{};

        AdminSekolah createdAdmin;
        if (dataMap.isNotEmpty) {
          createdAdmin = AdminSekolah.fromJson(dataMap);
          if (createdAdmin.sekolahNama.isEmpty && (sekolahNama != null && sekolahNama.isNotEmpty)) {
            createdAdmin = createdAdmin.copyWith(sekolahNama: sekolahNama);
          }
        } else {
          createdAdmin = AdminSekolah(
            id: 'adm-${DateTime.now().millisecondsSinceEpoch}',
            nama: effectiveNama,
            email: email ?? '',
            sekolahId: sekolahId,
            sekolahNama: sekolahNama ?? '',
            telepon: telepon,
          );
        }

        _admins.insert(0, createdAdmin);
        notifyListeners();

        return ApiResponse<AdminSekolah>(
          success: true,
          message: responseData['message']?.toString() ?? 'Admin berhasil ditambahkan',
          data: createdAdmin,
        );
      } else {
        return ApiResponse<AdminSekolah>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menambahkan admin (${response.statusCode})',
        );
      }
    } on SocketException {
      return const ApiResponse<AdminSekolah>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<AdminSekolah>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error createAdmin: $e');
      return ApiResponse<AdminSekolah>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// PUT /api/admin/{id}
  /// Update data admin
  /// Body: { "nama_admin": "...", "sekolah_id": "...", "password": "..." }
  Future<ApiResponse<AdminSekolah>> updateAdmin(
    String id, {
    String? nama,
    String? namaAdmin,
    required String sekolahId,
    String? email,
    String? password,
    String? sekolahNama,
    String? telepon,
    bool? isActive,
  }) async {
    final effectiveNama = (namaAdmin ?? nama ?? '').trim();
    final token = await _getToken();

    // Fallback in-memory jika belum autentikasi
    if (token == null || token.isEmpty) {
      final index = _admins.indexWhere((a) => a.id == id);
      if (index == -1) {
        return const ApiResponse<AdminSekolah>(
          success: false,
          message: 'Data admin tidak ditemukan.',
        );
      }

      final emailClean = (email ?? '').trim().toLowerCase();
      if (emailClean.isNotEmpty) {
        final emailExists = _admins.any(
          (a) => a.id != id && a.email.toLowerCase() == emailClean,
        );
        if (emailExists) {
          return const ApiResponse<AdminSekolah>(
            success: false,
            message: 'Email sudah digunakan oleh admin lain.',
          );
        }
      }

      final current = _admins[index];
      final updated = current.copyWith(
        nama: effectiveNama.isNotEmpty ? effectiveNama : current.nama,
        email: emailClean.isNotEmpty ? emailClean : current.email,
        sekolahId: sekolahId,
        sekolahNama: sekolahNama ?? current.sekolahNama,
        telepon: telepon?.trim().isEmpty ?? true ? null : telepon!.trim(),
        isActive: isActive ?? current.isActive,
        updatedAt: DateTime.now().toIso8601String(),
      );

      _admins[index] = updated;
      notifyListeners();

      return ApiResponse<AdminSekolah>(
        success: true,
        message: 'Data admin berhasil diperbarui',
        data: updated,
      );
    }

    try {
      final bodyMap = <String, dynamic>{
        'nama_admin': effectiveNama,
        'sekolah_id': sekolahId,
      };

      if (password != null && password.isNotEmpty) {
        bodyMap['password'] = password;
      }

      final response = await ApiClient.instance.put(
        ApiConfig.adminDetailUri(id),
        token: token,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 401) {
        return const ApiResponse<AdminSekolah>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      Map<String, dynamic> responseData = {};
      try {
        if (response.body.trim().isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            responseData = decoded;
          }
        }
      } catch (_) {}

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final dataMap = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : null;

        final index = _admins.indexWhere((a) => a.id == id);
        AdminSekolah updated;

        if (dataMap != null) {
          updated = AdminSekolah.fromJson(dataMap);
          if (updated.sekolahNama.isEmpty && sekolahNama != null) {
            updated = updated.copyWith(sekolahNama: sekolahNama);
          }
        } else if (index != -1) {
          final current = _admins[index];
          updated = current.copyWith(
            nama: effectiveNama.isNotEmpty ? effectiveNama : current.nama,
            sekolahId: sekolahId,
            sekolahNama: sekolahNama ?? current.sekolahNama,
            email: (email != null && email.isNotEmpty) ? email.trim() : current.email,
            telepon: telepon ?? current.telepon,
            isActive: isActive ?? current.isActive,
            updatedAt: DateTime.now().toIso8601String(),
          );
        } else {
          updated = AdminSekolah(
            id: id,
            nama: effectiveNama,
            email: email ?? '',
            sekolahId: sekolahId,
            sekolahNama: sekolahNama ?? '',
            telepon: telepon,
            isActive: isActive ?? true,
          );
        }

        if (index != -1) {
          _admins[index] = updated;
        }
        notifyListeners();

        return ApiResponse<AdminSekolah>(
          success: true,
          message: responseData['message']?.toString() ?? 'Data admin berhasil diperbarui',
          data: updated,
        );
      } else {
        return ApiResponse<AdminSekolah>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memperbarui data admin (${response.statusCode})',
        );
      }
    } on SocketException {
      return const ApiResponse<AdminSekolah>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<AdminSekolah>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error updateAdmin: $e');
      return ApiResponse<AdminSekolah>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// DELETE /api/admin/{id}
  /// Hapus data admin sekolah.
  Future<ApiResponse<void>> deleteAdmin(String id) async {
    final token = await _getToken();

    // Fallback in-memory jika belum autentikasi
    if (token == null || token.isEmpty) {
      final index = _admins.indexWhere((a) => a.id == id);
      if (index == -1) {
        return const ApiResponse<void>(
          success: false,
          message: 'Data admin tidak ditemukan.',
        );
      }

      _admins.removeAt(index);
      notifyListeners();

      return const ApiResponse<void>(
        success: true,
        message: 'Admin per sekolah berhasil dihapus',
      );
    }

    try {
      final response = await ApiClient.instance.delete(
        ApiConfig.adminDetailUri(id),
        token: token,
      );

      if (response.statusCode == 401) {
        return const ApiResponse<void>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      Map<String, dynamic> responseData = {};
      try {
        if (response.body.trim().isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            responseData = decoded;
          }
        }
      } catch (_) {}

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        _admins.removeWhere((a) => a.id == id);
        notifyListeners();

        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Admin per sekolah berhasil dihapus',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menghapus admin',
        );
      }
    } on SocketException {
      return const ApiResponse<void>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<void>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error deleteAdmin: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
