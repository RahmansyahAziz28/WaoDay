/// A school record.
class Sekolah {
  const Sekolah({
    required this.id,
    required this.nama,
    this.alamat,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nama;
  final String? alamat;
  final String? createdAt;
  final String? updatedAt;

  String get namaSekolah => nama;

  factory Sekolah.fromJson(Map<String, dynamic> json) {
    return Sekolah(
      id: json['id']?.toString() ?? '',
      nama: json['nama_sekolah']?.toString() ?? json['nama']?.toString() ?? '',
      alamat: json['alamat']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama_sekolah': nama,
    if (alamat != null) 'alamat': alamat,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };
}

/// Paginated Sekolah Response Model according to API GET /api/sekolah?page=1&limit=20
class PaginatedSekolahResponse {
  final bool success;
  final int count;
  final int page;
  final int limit;
  final List<Sekolah> data;
  final String? message;

  const PaginatedSekolahResponse({
    required this.success,
    required this.count,
    required this.page,
    required this.limit,
    required this.data,
    this.message,
  });

  factory PaginatedSekolahResponse.fromJson(
    Map<String, dynamic> json, {
    int defaultPage = 1,
    int defaultLimit = 20,
  }) {
    final rawList = json['data'];
    final List<Sekolah> items = [];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map) {
          items.add(Sekolah.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return PaginatedSekolahResponse(
      success: json['success'] == true,
      count: int.tryParse(json['count']?.toString() ?? '') ?? items.length,
      page: int.tryParse(json['page']?.toString() ?? '') ?? defaultPage,
      limit: int.tryParse(json['limit']?.toString() ?? '') ?? defaultLimit,
      data: items,
      message: json['message']?.toString(),
    );
  }
}
