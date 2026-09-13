class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://localhost:3000';

  static const String loginEndpoint = '/api/auth/login';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String dashboardGuruEndpoint = '/api/dashboard/guru';

  static Uri get loginUri => Uri.parse('$baseUrl$loginEndpoint');
  static Uri get logoutUri => Uri.parse('$baseUrl$logoutEndpoint');
  static Uri get dashboardGuruUri =>
      Uri.parse('$baseUrl$dashboardGuruEndpoint');

  static Uri get guruBaseUri => Uri.parse('$baseUrl/api/guru');
  static Uri guruUri({int? page, int? limit}) {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;
    return uri('/api/guru', query.isNotEmpty ? query : null);
  }

  static Uri guruDetailUri(String id) => Uri.parse('$baseUrl/api/guru/$id');

  static Uri get sekolahBaseUri => Uri.parse('$baseUrl/api/sekolah');
  static Uri get sekolahUri => Uri.parse('$baseUrl/api/sekolah');
  static Uri sekolahPaginatedUri({int? page, int? limit}) {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;
    return uri('/api/sekolah', query.isNotEmpty ? query : null);
  }

  static Uri sekolahDetailUri(String id) =>
      Uri.parse('$baseUrl/api/sekolah/$id');

  // ── Kelas ──────────────────────────────────────────────────────────────────
  static Uri get kelasUri => Uri.parse('$baseUrl/api/kelas');
  static Uri kelasDetailUri(String id) => Uri.parse('$baseUrl/api/kelas/$id');
  static Uri kelasSiswaUri(String id) =>
      Uri.parse('$baseUrl/api/kelas/$id/siswa');

  // ── Siswa ──────────────────────────────────────────────────────────────────
  static Uri get siswaUri => Uri.parse('$baseUrl/api/siswa');
  static Uri siswaDetailUri(String id) => Uri.parse('$baseUrl/api/siswa/$id');

  // ── Admin ──────────────────────────────────────────────────────────────────
  static Uri get adminUri => Uri.parse('$baseUrl/api/admin');
  static Uri adminQueryUri({
    String? sekolahId,
    String? search,
    int? page,
    int? limit,
  }) {
    final query = <String, dynamic>{};
    if (sekolahId != null && sekolahId.isNotEmpty && sekolahId != 'all') {
      query['sekolah_id'] = sekolahId;
    }
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;
    return uri('/api/admin', query.isNotEmpty ? query : null);
  }

  static Uri adminDetailUri(String id) => Uri.parse('$baseUrl/api/admin/$id');

  // ── Game Token & Materi ────────────────────────────────────────────────────
  static Uri get gameTokenUri => Uri.parse('$baseUrl/api/game/token');

  static Uri gameTokensByKelasUri(String kelasId) =>
      uri('/api/game/token', {'kelas_id': kelasId});

  static Uri gameTokenNilaiUri(String tokenId, {int kkm = 70}) =>
      uri('/api/game/token/$tokenId/nilai', {'kkm': kkm});

  static Uri materiUri({int? tingkatKelas, int? semester, String? mataPelajaran}) {
    final query = <String, dynamic>{};
    if (tingkatKelas != null) query['tingkat_kelas'] = tingkatKelas;
    if (semester != null) query['semester'] = semester;
    if (mataPelajaran != null && mataPelajaran.isNotEmpty) {
      query['mata_pelajaran'] = mataPelajaran;
    }
    return uri('/api/materi', query.isNotEmpty ? query : null);
  }

  static Uri uri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$baseUrl$cleanEndpoint').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
