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
