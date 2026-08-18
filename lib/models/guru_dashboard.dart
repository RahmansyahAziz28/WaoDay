class SekolahInfo {
  final String id;
  final String namaSekolah;
  final String? alamat;

  const SekolahInfo({
    required this.id,
    required this.namaSekolah,
    this.alamat,
  });

  factory SekolahInfo.fromJson(Map<String, dynamic> json) {
    return SekolahInfo(
      id: json['id']?.toString() ?? '',
      namaSekolah: json['nama_sekolah']?.toString() ?? '',
      alamat: json['alamat']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama_sekolah': namaSekolah,
    if (alamat != null) 'alamat': alamat,
  };
}

class GuruProfil {
  final String id;
  final String userId;
  final String namaGuru;
  final String nim;
  final String? sekolahId;
  final String? createdAt;
  final String? updatedAt;
  final SekolahInfo? sekolah;

  const GuruProfil({
    required this.id,
    required this.userId,
    required this.namaGuru,
    required this.nim,
    this.sekolahId,
    this.createdAt,
    this.updatedAt,
    this.sekolah,
  });

  factory GuruProfil.fromJson(Map<String, dynamic> json) {
    return GuruProfil(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      namaGuru: json['nama_guru']?.toString() ?? '',
      nim: json['nim']?.toString() ?? '',
      sekolahId: json['sekolah_id']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      sekolah: json['sekolah'] is Map<String, dynamic>
          ? SekolahInfo.fromJson(json['sekolah'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'nama_guru': namaGuru,
    'nim': nim,
    if (sekolahId != null) 'sekolah_id': sekolahId,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
    if (sekolah != null) 'sekolah': sekolah!.toJson(),
  };
}

class GuruStatistik {
  final int totalKelas;
  final int totalSiswa;

  const GuruStatistik({
    required this.totalKelas,
    required this.totalSiswa,
  });

  factory GuruStatistik.fromJson(Map<String, dynamic> json) {
    return GuruStatistik(
      totalKelas: int.tryParse(json['total_kelas']?.toString() ?? '') ?? 0,
      totalSiswa: int.tryParse(json['total_siswa']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_kelas': totalKelas,
    'total_siswa': totalSiswa,
  };
}

class GuruKelasItem {
  final String id;
  final String kodeKelas;
  final String namaKelas;

  const GuruKelasItem({
    required this.id,
    required this.kodeKelas,
    required this.namaKelas,
  });

  factory GuruKelasItem.fromJson(Map<String, dynamic> json) {
    return GuruKelasItem(
      id: json['id']?.toString() ?? '',
      kodeKelas: json['kode_kelas']?.toString() ?? '',
      namaKelas: json['nama_kelas']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kode_kelas': kodeKelas,
    'nama_kelas': namaKelas,
  };
}

class GuruDashboardData {
  final GuruProfil profil;
  final GuruStatistik statistik;
  final List<GuruKelasItem> kelas;
  final List<dynamic> siswa;

  const GuruDashboardData({
    required this.profil,
    required this.statistik,
    required this.kelas,
    required this.siswa,
  });

  factory GuruDashboardData.fromJson(Map<String, dynamic> json) {
    return GuruDashboardData(
      profil: json['profil'] is Map<String, dynamic>
          ? GuruProfil.fromJson(json['profil'] as Map<String, dynamic>)
          : const GuruProfil(id: '', userId: '', namaGuru: '', nim: ''),
      statistik: json['statistik'] is Map<String, dynamic>
          ? GuruStatistik.fromJson(json['statistik'] as Map<String, dynamic>)
          : const GuruStatistik(totalKelas: 0, totalSiswa: 0),
      kelas: json['kelas'] is List
          ? (json['kelas'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => GuruKelasItem.fromJson(e))
              .toList()
          : <GuruKelasItem>[],
      siswa: json['siswa'] is List ? (json['siswa'] as List) : <dynamic>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'profil': profil.toJson(),
    'statistik': statistik.toJson(),
    'kelas': kelas.map((e) => e.toJson()).toList(),
    'siswa': siswa,
  };
}
