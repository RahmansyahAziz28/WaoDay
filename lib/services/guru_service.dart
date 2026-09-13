import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../data/dummy_data.dart';
import '../models/auth_user.dart';
import '../models/guru_dashboard.dart';
import 'api_client.dart';
import 'auth_service.dart';

class GuruService {
  GuruService._internal();

  static final GuruService instance = GuruService._internal();

  Future<ApiResponse<GuruDashboardData>> getDashboardData() async {
    final token = await AuthService.instance.getToken() ?? AppData.instance.token;

    if (token == null || token.isEmpty) {
      return const ApiResponse<GuruDashboardData>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final response = await ApiClient.instance.get(
        ApiConfig.dashboardGuruUri,
        token: token,
      );

      if (response.statusCode == 401) {
        return const ApiResponse<GuruDashboardData>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300 && responseData['success'] == true) {
        final data = GuruDashboardData.fromJson(responseData['data'] as Map<String, dynamic>? ?? {});

        AppData.instance.setGuruDashboardData(data);

        return ApiResponse<GuruDashboardData>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil mengambil data dashboard guru',
          data: data,
        );
      } else {
        return ApiResponse<GuruDashboardData>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal mengambil data dashboard guru',
        );
      }
    } on SocketException {
      return const ApiResponse<GuruDashboardData>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<GuruDashboardData>(
        success: false,
        message: 'Koneksi ke server time out. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error fetching guru dashboard: $e');
      return ApiResponse<GuruDashboardData>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
