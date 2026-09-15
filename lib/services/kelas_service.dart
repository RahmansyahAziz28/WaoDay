import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../data/dummy_data.dart';
import '../models/auth_user.dart';
import '../models/kelas.dart';
import '../models/siswa.dart';
import 'api_client.dart';
import 'auth_service.dart';

class KelasService {
  KelasService._internal();

  static final KelasService instance = KelasService._internal();

  Future<String?> _getToken() async {
    return await AuthService.instance.getToken() ?? AppData.instance.token;
  }

  // ── KELAS CRUD ─────────────────────────────────────────────────────────────

  /// GET /api/kelas
  Future<ApiResponse<List<Kelas>>> getKelas() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<List<Kelas>>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final response = await ApiClient.instance.get(
        ApiConfig.kelasUri,
        token: token,
      );

      if (response.statusCode == 401) {
        return const ApiResponse<List<Kelas>>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rawData = responseData['data'];
        List<Kelas> list = [];
        if (rawData is List) {
          list = rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => Kelas.fromJson(e))
              .toList();
        }
        return ApiResponse<List<Kelas>>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat kelas',
          data: list,
        );
      } else {
        return ApiResponse<List<Kelas>>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat daftar kelas',
        );
      }
    } on SocketException {
      return const ApiResponse<List<Kelas>>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<List<Kelas>>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error getKelas: $e');
      return ApiResponse<List<Kelas>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/kelas/:id
  Future<ApiResponse<Kelas>> getKelasDetail(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<Kelas>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await ApiClient.instance.get(
        ApiConfig.kelasDetailUri(id),
        token: token,
      );

      if (response.statusCode == 401) {
        return const ApiResponse<Kelas>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final dataMap = responseData['data'] as Map<String, dynamic>? ?? {};
        final kelas = Kelas.fromJson(dataMap);
        return ApiResponse<Kelas>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat detail kelas',
          data: kelas,
        );
      } else {
        return ApiResponse<Kelas>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat detail kelas',
        );
      }
    } catch (e) {
      debugPrint('Error getKelasDetail: $e');
      return ApiResponse<Kelas>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST /api/kelas
  /// Body: { kode_kelas, nama_kelas, nama_sekolah, [sekolah_id], [guru_id], [tingkat] }
  Future<ApiResponse<void>> createKelas({
    required String kodeKelas,
    required String namaKelas,
    String? namaSekolah,
    String? sekolahId,
    String? guruId,
    int? tingkat,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final effectiveSekolah = (namaSekolah != null && namaSekolah.trim().isNotEmpty)
          ? namaSekolah.trim()
          : (AppData.instance.guruDashboardData?.profil.sekolah?.namaSekolah ??
              AppData.instance.currentGuru?.sekolah ??
              '');
      final effectiveSekolahId = (sekolahId != null && sekolahId.trim().isNotEmpty)
          ? sekolahId.trim()
          : (AppData.instance.guruDashboardData?.profil.sekolahId ??
              AppData.instance.guruDashboardData?.profil.sekolah?.id);

      final Map<String, dynamic> bodyMap = {
        'kode_kelas': kodeKelas.trim(),
        'nama_kelas': namaKelas.trim(),
      };
      if (effectiveSekolah.isNotEmpty) {
        bodyMap['nama_sekolah'] = effectiveSekolah;
      }
      if (effectiveSekolahId != null && effectiveSekolahId.isNotEmpty) {
        bodyMap['sekolah_id'] = effectiveSekolahId;
      }
      if (guruId != null && guruId.trim().isNotEmpty) {
        bodyMap['guru_id'] = guruId.trim();
      }
      if (tingkat != null) {
        bodyMap['tingkat'] = tingkat;
      }

      final response = await ApiClient.instance.post(
        ApiConfig.kelasUri,
        token: token,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 401) {
        return const ApiResponse<void>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Kelas berhasil dibuat',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal membuat kelas',
        );
      }
    } catch (e) {
      debugPrint('Error createKelas: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// PUT /api/kelas/:id
  /// Body: { kode_kelas, nama_kelas, sekolah_id, guru_id, [nama_sekolah], [tingkat] }
  Future<ApiResponse<void>> updateKelas({
    required String id,
    required String kodeKelas,
    required String namaKelas,
    String? sekolahId,
    String? guruId,
    String? namaSekolah,
    int? tingkat,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final effectiveSekolahId = (sekolahId != null && sekolahId.trim().isNotEmpty)
          ? sekolahId.trim()
          : (AppData.instance.guruDashboardData?.profil.sekolahId ??
              AppData.instance.guruDashboardData?.profil.sekolah?.id ??
              '');
      final effectiveGuruId = (guruId != null && guruId.trim().isNotEmpty)
          ? guruId.trim()
          : (AppData.instance.guruDashboardData?.profil.id ??
              AppData.instance.currentUser?.id ??
              '');
      final effectiveNamaSekolah = (namaSekolah != null && namaSekolah.trim().isNotEmpty)
          ? namaSekolah.trim()
          : (AppData.instance.guruDashboardData?.profil.sekolah?.namaSekolah ??
              AppData.instance.currentGuru?.sekolah ??
              '');

      final Map<String, dynamic> bodyMap = {
        'kode_kelas': kodeKelas.trim(),
        'nama_kelas': namaKelas.trim(),
      };
      if (effectiveSekolahId.isNotEmpty) {
        bodyMap['sekolah_id'] = effectiveSekolahId;
      }
      if (effectiveGuruId.isNotEmpty) {
        bodyMap['guru_id'] = effectiveGuruId;
      }
      if (effectiveNamaSekolah.isNotEmpty) {
        bodyMap['nama_sekolah'] = effectiveNamaSekolah;
      }
      if (tingkat != null) {
        bodyMap['tingkat'] = tingkat;
      }

      final response = await ApiClient.instance.put(
        ApiConfig.kelasDetailUri(id),
        token: token,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 401) {
        return const ApiResponse<void>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Kelas berhasil diperbarui',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memperbarui kelas',
        );
      }
    } catch (e) {
      debugPrint('Error updateKelas: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// DELETE /api/kelas/:id
  Future<ApiResponse<void>> deleteKelas(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await ApiClient.instance.delete(
        ApiConfig.kelasDetailUri(id),
        token: token,
      );

      if (response.statusCode == 401) {
        return const ApiResponse<void>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Kelas berhasil dihapus',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menghapus kelas',
        );
      }
    } catch (e) {
      debugPrint('Error deleteKelas: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ── SISWA CRUD ─────────────────────────────────────────────────────────────

  /// GET /api/kelas/:id/siswa
  Future<ApiResponse<List<Siswa>>> getSiswaInKelas(String kelasId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<List<Siswa>>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await ApiClient.instance.get(
        ApiConfig.kelasSiswaUri(kelasId),
        token: token,
      );

      if (response.statusCode == 401) {
        return const ApiResponse<List<Siswa>>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rawData = responseData['data'];
        final kelasInfo = responseData['kelas'] is Map<String, dynamic>
            ? responseData['kelas'] as Map<String, dynamic>
            : null;
        final defaultKodeKelas = kelasInfo?['kode_kelas']?.toString() ??
            kelasInfo?['nama_kelas']?.toString() ??
            '';

        List<Siswa> list = [];
        if (rawData is List) {
          list = rawData.whereType<Map<String, dynamic>>().map((e) {
            final item = Map<String, dynamic>.from(e);
            if (!item.containsKey('kode_kelas') &&
                !item.containsKey('nama_kelas') &&
                defaultKodeKelas.isNotEmpty) {
              item['kode_kelas'] = defaultKodeKelas;
            }
            return Siswa.fromJson(item);
          }).toList();
        }
        return ApiResponse<List<Siswa>>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat daftar siswa',
          data: list,
        );
      } else {
        return ApiResponse<List<Siswa>>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat daftar siswa',
        );
      }
    } catch (e) {
      debugPrint('Error getSiswaInKelas: $e');
      return ApiResponse<List<Siswa>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST /api/siswa
  /// Body: { nama_siswa, nis, [nama_sekolah], [kode_kelas], [sekolah_id], [kelas_id] }
  Future<ApiResponse<void>> createSiswa({
    required String namaSiswa,
    required String nis,
    String? namaSekolah,
    String? kodeKelas,
    String? sekolahId,
    String? kelasId,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final effectiveSekolah = (namaSekolah != null && namaSekolah.trim().isNotEmpty)
          ? namaSekolah.trim()
          : (AppData.instance.guruDashboardData?.profil.sekolah?.namaSekolah ??
              AppData.instance.currentGuru?.sekolah ??
              '');
      final effectiveSekolahId = (sekolahId != null && sekolahId.trim().isNotEmpty)
          ? sekolahId.trim()
          : (AppData.instance.guruDashboardData?.profil.sekolahId ??
              AppData.instance.guruDashboardData?.profil.sekolah?.id);

      final Map<String, dynamic> bodyMap = {
        'nama_siswa': namaSiswa.trim(),
        'nis': nis.trim(),
      };
      if (effectiveSekolah.isNotEmpty) {
        bodyMap['nama_sekolah'] = effectiveSekolah;
      }
      if (kodeKelas != null && kodeKelas.trim().isNotEmpty) {
        bodyMap['kode_kelas'] = kodeKelas.trim();
      }
      if (effectiveSekolahId != null && effectiveSekolahId.isNotEmpty) {
        bodyMap['sekolah_id'] = effectiveSekolahId;
      }
      if (kelasId != null && kelasId.trim().isNotEmpty) {
        bodyMap['kelas_id'] = kelasId.trim();
      }

      final response = await ApiClient.instance.post(
        ApiConfig.siswaUri,
        token: token,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 401) {
        return const ApiResponse<void>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Siswa berhasil ditambahkan',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menambahkan siswa',
        );
      }
    } catch (e) {
      debugPrint('Error createSiswa: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// PUT /api/siswa/:id
  /// Body: { nama_siswa, nis, [sekolah_id], [nama_sekolah], [kode_kelas], [kelas_id] }
  Future<ApiResponse<void>> updateSiswa({
    required String id,
    required String namaSiswa,
    required String nis,
    String? sekolahId,
    String? namaSekolah,
    String? kodeKelas,
    String? kelasId,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final effectiveSekolahId = (sekolahId != null && sekolahId.trim().isNotEmpty)
          ? sekolahId.trim()
          : (AppData.instance.guruDashboardData?.profil.sekolahId ??
              AppData.instance.guruDashboardData?.profil.sekolah?.id ??
              '');

      final Map<String, dynamic> bodyMap = {
        'nama_siswa': namaSiswa.trim(),
        'nis': nis.trim(),
      };
      if (effectiveSekolahId.isNotEmpty) {
        bodyMap['sekolah_id'] = effectiveSekolahId;
      }
      if (namaSekolah != null && namaSekolah.trim().isNotEmpty) {
        bodyMap['nama_sekolah'] = namaSekolah.trim();
      }
      if (kodeKelas != null && kodeKelas.trim().isNotEmpty) {
        bodyMap['kode_kelas'] = kodeKelas.trim();
      }
      if (kelasId != null && kelasId.trim().isNotEmpty) {
        bodyMap['kelas_id'] = kelasId.trim();
      }

      final response = await ApiClient.instance.put(
        ApiConfig.siswaDetailUri(id),
        token: token,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 401) {
        return const ApiResponse<void>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Data siswa berhasil diperbarui',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memperbarui data siswa',
        );
      }
    } catch (e) {
      debugPrint('Error updateSiswa: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// DELETE /api/siswa/:id
  Future<ApiResponse<void>> deleteSiswa(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await ApiClient.instance.delete(
        ApiConfig.siswaDetailUri(id),
        token: token,
      );

      if (response.statusCode == 401) {
        return const ApiResponse<void>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Siswa berhasil dihapus',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menghapus siswa',
        );
      }
    } catch (e) {
      debugPrint('Error deleteSiswa: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
