class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://sekolah-neon.vercel.app';

  static const String loginEndpoint = '/api/auth/login';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String dashboardGuruEndpoint = '/api/dashboard/guru';

  static Uri get loginUri => Uri.parse('$baseUrl$loginEndpoint');
  static Uri get logoutUri => Uri.parse('$baseUrl$logoutEndpoint');
  static Uri get dashboardGuruUri => Uri.parse('$baseUrl$dashboardGuruEndpoint');

  // ── Kelas ──────────────────────────────────────────────────────────────────
  static Uri get kelasUri => Uri.parse('$baseUrl/api/kelas');
  static Uri kelasDetailUri(String id) => Uri.parse('$baseUrl/api/kelas/$id');
  static Uri kelasSiswaUri(String id) => Uri.parse('$baseUrl/api/kelas/$id/siswa');

  // ── Siswa ──────────────────────────────────────────────────────────────────
  static Uri get siswaUri => Uri.parse('$baseUrl/api/siswa');
  static Uri siswaDetailUri(String id) => Uri.parse('$baseUrl/api/siswa/$id');

  static Uri uri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$baseUrl$cleanEndpoint').replace(
      queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())),
    );
  }
}
