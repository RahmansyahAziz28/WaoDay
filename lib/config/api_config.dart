class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://sekolah-neon.vercel.app';

  static const String loginEndpoint = '/api/auth/login';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String dashboardGuruEndpoint = '/api/dashboard/guru';

  static Uri get loginUri => Uri.parse('$baseUrl$loginEndpoint');
  static Uri get logoutUri => Uri.parse('$baseUrl$logoutEndpoint');
  static Uri get dashboardGuruUri => Uri.parse('$baseUrl$dashboardGuruEndpoint');

  // ── Guru ───────────────────────────────────────────────────────────────────
  static Uri guruUri({int? page, int? limit}) {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;
    return uri('/api/guru', query.isNotEmpty ? query : null);
  }
  static Uri guruDetailUri(String id) => Uri.parse('$baseUrl/api/guru/$id');

  // ── Sekolah ────────────────────────────────────────────────────────────────
  static Uri get sekolahUri => Uri.parse('$baseUrl/api/sekolah');
  static Uri sekolahDetailUri(String id) => Uri.parse('$baseUrl/api/sekolah/$id');

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
