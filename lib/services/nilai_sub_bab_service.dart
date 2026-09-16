import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../config/api_config.dart';
import '../data/dummy_data.dart';
import '../models/auth_user.dart';
import '../models/nilai_sub_bab.dart';
import 'api_client.dart';
import 'auth_service.dart';

class NilaiSubBabService {
  NilaiSubBabService._internal();

  static final NilaiSubBabService instance = NilaiSubBabService._internal();

  Future<String?> _getToken() async {
    return await AuthService.instance.getToken() ?? AppData.instance.token;
  }

  /// GET /api/kelas/{kelas_id}/nilai-sub-bab?kkm=70
  Future<ApiResponse<RekapNilaiKelasResponse>> getNilaiSubBabKelas(
    String kelasId, {
    int kkm = 70,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<RekapNilaiKelasResponse>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final uri = ApiConfig.kelasNilaiSubBabUri(kelasId, kkm: kkm);
      final response = await ApiClient.instance.get(uri, token: token);

      if (response.statusCode == 401) {
        return const ApiResponse<RekapNilaiKelasResponse>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rekap = RekapNilaiKelasResponse.fromJson(responseData);
        return ApiResponse<RekapNilaiKelasResponse>(
          success: true,
          message: responseData['message']?.toString() ??
              'Berhasil memuat rekap nilai sub-bab',
          data: rekap,
        );
      } else {
        return ApiResponse<RekapNilaiKelasResponse>(
          success: false,
          message: responseData['message']?.toString() ??
              'Gagal memuat rekap nilai sub-bab kelas',
        );
      }
    } on SocketException {
      return const ApiResponse<RekapNilaiKelasResponse>(
        success: false,
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<RekapNilaiKelasResponse>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error getNilaiSubBabKelas: $e');
      return ApiResponse<RekapNilaiKelasResponse>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/siswa/{siswa_id}/nilai-sub-bab?kkm=70
  Future<ApiResponse<RaporNilaiSiswaResponse>> getNilaiSubBabSiswa(
    String siswaId, {
    int kkm = 70,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<RaporNilaiSiswaResponse>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final uri = ApiConfig.siswaNilaiSubBabUri(siswaId, kkm: kkm);
      final response = await ApiClient.instance.get(uri, token: token);

      if (response.statusCode == 401) {
        return const ApiResponse<RaporNilaiSiswaResponse>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rapor = RaporNilaiSiswaResponse.fromJson(responseData);
        return ApiResponse<RaporNilaiSiswaResponse>(
          success: true,
          message: responseData['message']?.toString() ??
              'Berhasil memuat rapor nilai sub-bab siswa',
          data: rapor,
        );
      } else {
        return ApiResponse<RaporNilaiSiswaResponse>(
          success: false,
          message: responseData['message']?.toString() ??
              'Gagal memuat rapor nilai siswa',
        );
      }
    } on SocketException {
      return const ApiResponse<RaporNilaiSiswaResponse>(
        success: false,
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<RaporNilaiSiswaResponse>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error getNilaiSubBabSiswa: $e');
      return ApiResponse<RaporNilaiSiswaResponse>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/game/token/{token_id}/export-excel?kkm=70
  /// Downloads binary stream .xlsx and saves to local storage directory.
  Future<ApiResponse<File>> downloadExportExcelToken(
    String tokenId, {
    String? fileName,
    int kkm = 70,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<File>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final uri = ApiConfig.gameTokenExportExcelUri(tokenId, kkm: kkm);
      final response = await ApiClient.instance.get(
        uri,
        token: token,
        headers: {
          'Accept':
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/octet-stream, */*',
        },
      );

      if (response.statusCode == 401) {
        return const ApiResponse<File>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final cleanName = fileName != null && fileName.trim().isNotEmpty
            ? fileName.trim()
            : 'Rekap_Nilai_Token_${tokenId.substring(0, tokenId.length > 8 ? 8 : tokenId.length)}.xlsx';

        // Ensure proper .xlsx extension
        final finalFileName =
            cleanName.endsWith('.xlsx') ? cleanName : '$cleanName.xlsx';

        File? savedFile;

        // 1. Prioritas Utama di Android: Folder Download publik (/storage/emulated/0/Download)
        if (Platform.isAndroid) {
          try {
            final publicDownloadDir = Directory('/storage/emulated/0/Download');
            if (!publicDownloadDir.existsSync()) {
              publicDownloadDir.createSync(recursive: true);
            }
            final targetFile = File('${publicDownloadDir.path}/$finalFileName');
            await targetFile.writeAsBytes(response.bodyBytes, flush: true);
            savedFile = targetFile;
          } catch (e) {
            debugPrint('Gagal simpan ke /storage/emulated/0/Download: $e');
          }

          // 2. Jika gagal, coba via getExternalStorageDirectories(type: StorageDirectory.downloads)
          if (savedFile == null) {
            try {
              final extDirs = await getExternalStorageDirectories(
                type: StorageDirectory.downloads,
              );
              if (extDirs != null && extDirs.isNotEmpty) {
                final targetFile = File('${extDirs.first.path}/$finalFileName');
                await targetFile.writeAsBytes(response.bodyBytes, flush: true);
                savedFile = targetFile;
              }
            } catch (e) {
              debugPrint('Gagal simpan ke external download directory: $e');
            }
          }
        } else {
          // iOS / Desktop: gunakan getDownloadsDirectory
          try {
            final downloadDir = await getDownloadsDirectory();
            if (downloadDir != null) {
              final targetFile = File('${downloadDir.path}/$finalFileName');
              await targetFile.writeAsBytes(response.bodyBytes, flush: true);
              savedFile = targetFile;
            }
          } catch (e) {
            debugPrint('Gagal simpan ke getDownloadsDirectory: $e');
          }
        }

        // 3. Fallback jika semua direktori download tidak bisa diakses
        if (savedFile == null) {
          Directory fallbackDir;
          try {
            fallbackDir = await getApplicationDocumentsDirectory();
          } catch (_) {
            fallbackDir = await getTemporaryDirectory();
          }
          final fallbackFile = File('${fallbackDir.path}/$finalFileName');
          await fallbackFile.writeAsBytes(response.bodyBytes, flush: true);
          savedFile = fallbackFile;
        }

        return ApiResponse<File>(
          success: true,
          message: 'File Excel berhasil disimpan di folder Download',
          data: savedFile,
        );
      } else {
        // Try parsing error message from JSON response body if available
        String errorMessage = 'Gagal mengunduh file Excel (${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        } catch (_) {}

        return ApiResponse<File>(
          success: false,
          message: errorMessage,
        );
      }
    } on SocketException {
      return const ApiResponse<File>(
        success: false,
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<File>(
        success: false,
        message: 'Koneksi ke server timeout saat mengunduh file Excel.',
      );
    } catch (e) {
      debugPrint('Error downloadExportExcelToken: $e');
      return ApiResponse<File>(
        success: false,
        message: 'Terjadi kesalahan saat mengunduh Excel: ${e.toString()}',
      );
    }
  }
}
