import 'guru_dashboard.dart';

/// A teacher record.
class Guru {
  const Guru({
    required this.id,
    required this.nama,
    required this.nim,
    required this.sekolah,
    required this.kodeKelas,
    this.userId,
    this.sekolahId,
    this.sekolahInfo,
    this.kelasList = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nama;
  final String nim;
  final String sekolah;
  final String kodeKelas;
  final String? userId;
  final String? sekolahId;
  final SekolahInfo? sekolahInfo;
  final List<GuruKelasItem> kelasList;
  final String? createdAt;
  final String? updatedAt;

  String get namaGuru => nama;

  factory Guru.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? sekolahMap;
    if (json['sekolah'] is Map) {
      sekolahMap = Map<String, dynamic>.from(json['sekolah'] as Map);
    }

    final List<GuruKelasItem> parsedKelas = [];
    if (json['kelas'] is List) {
      for (final k in json['kelas'] as List) {
        if (k is Map) {
          parsedKelas.add(GuruKelasItem.fromJson(Map<String, dynamic>.from(k)));
        }
      }
    }

    final primaryKodeKelas = parsedKelas.isNotEmpty
        ? parsedKelas.first.kodeKelas
        : (json['kode_kelas']?.toString() ?? '-');

    final schoolName = sekolahMap?['nama_sekolah']?.toString() ??
        json['nama_sekolah']?.toString() ??
        (json['sekolah'] is String ? json['sekolah'].toString() : '-');

    return Guru(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      nama: json['nama_guru']?.toString() ?? json['nama']?.toString() ?? '',
      nim: json['nim']?.toString() ?? '',
      sekolah: schoolName,
      sekolahId: json['sekolah_id']?.toString() ?? sekolahMap?['id']?.toString(),
      sekolahInfo: sekolahMap != null ? SekolahInfo.fromJson(sekolahMap) : null,
      kodeKelas: primaryKodeKelas,
      kelasList: parsedKelas,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama_guru': nama,
    'nim': nim,
    if (userId != null) 'user_id': userId,
    if (sekolahId != null) 'sekolah_id': sekolahId,
    if (sekolahInfo != null) 'sekolah': sekolahInfo!.toJson(),
    'kelas': kelasList.map((e) => e.toJson()).toList(),
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };
}

/// Paginated Guru Response Model according to API GET /api/guru
class PaginatedGuruResponse {
  final bool success;
  final int count;
  final int page;
  final int limit;
  final List<Guru> data;
  final String? message;

  const PaginatedGuruResponse({
    required this.success,
    required this.count,
    required this.page,
    required this.limit,
    required this.data,
    this.message,
  });

  factory PaginatedGuruResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final List<Guru> items = [];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map) {
          items.add(Guru.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return PaginatedGuruResponse(
      success: json['success'] == true,
      count: int.tryParse(json['count']?.toString() ?? '') ?? items.length,
      page: int.tryParse(json['page']?.toString() ?? '') ?? 1,
      limit: int.tryParse(json['limit']?.toString() ?? '') ?? 20,
      data: items,
      message: json['message']?.toString(),
    );
  }
}
