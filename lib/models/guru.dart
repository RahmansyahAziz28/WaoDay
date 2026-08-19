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
    final sekolahMap = json['sekolah'] is Map<String, dynamic>
        ? json['sekolah'] as Map<String, dynamic>
        : null;

    final List<GuruKelasItem> parsedKelas = json['kelas'] is List
        ? (json['kelas'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => GuruKelasItem.fromJson(e))
            .toList()
        : <GuruKelasItem>[];

    final primaryKodeKelas = parsedKelas.isNotEmpty
        ? parsedKelas.first.kodeKelas
        : (json['kode_kelas']?.toString() ?? '-');

    final schoolName = sekolahMap?['nama_sekolah']?.toString() ??
        json['nama_sekolah']?.toString() ??
        json['sekolah']?.toString() ??
        '-';

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
