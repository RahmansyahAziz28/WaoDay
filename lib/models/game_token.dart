/// Model for Game Token item in list / per-class view
class GameTokenItem {
  final String id;
  final String kodeToken;
  final String namaSesi;
  final int? tingkatKelas;
  final int? semester;
  final int jumlahSoal;
  final bool acak;
  final bool aktif;
  final bool izinkanOffline;
  final int totalPemain;
  final String? createdAt;
  final String? kelasId;

  const GameTokenItem({
    required this.id,
    required this.kodeToken,
    required this.namaSesi,
    this.tingkatKelas,
    this.semester,
    required this.jumlahSoal,
    this.acak = true,
    this.aktif = true,
    this.izinkanOffline = true,
    this.totalPemain = 0,
    this.createdAt,
    this.kelasId,
  });

  factory GameTokenItem.fromJson(Map<String, dynamic> json) {
    return GameTokenItem(
      id: json['id']?.toString() ?? '',
      kodeToken: json['kode_token']?.toString() ?? '',
      namaSesi: json['nama_sesi']?.toString() ?? '',
      tingkatKelas: int.tryParse(json['tingkat_kelas']?.toString() ?? ''),
      semester: int.tryParse(json['semester']?.toString() ?? ''),
      jumlahSoal: int.tryParse(json['jumlah_soal']?.toString() ?? '') ?? 0,
      acak: json['acak'] == null ? true : (json['acak'] == true || json['acak'] == 1),
      aktif: json['aktif'] == null ? true : (json['aktif'] == true || json['aktif'] == 1),
      izinkanOffline: json['izinkan_offline'] == null
          ? true
          : (json['izinkan_offline'] == true || json['izinkan_offline'] == 1),
      totalPemain: int.tryParse(json['total_pemain']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString(),
      kelasId: json['kelas_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kode_token': kodeToken,
        'nama_sesi': namaSesi,
        if (tingkatKelas != null) 'tingkat_kelas': tingkatKelas,
        if (semester != null) 'semester': semester,
        'jumlah_soal': jumlahSoal,
        'acak': acak,
        'aktif': aktif,
        'izinkan_offline': izinkanOffline,
        'total_pemain': totalPemain,
        if (createdAt != null) 'created_at': createdAt,
        if (kelasId != null) 'kelas_id': kelasId,
      };
}

/// Paket Ujian info inside Rekap Nilai response
class PaketUjianInfo {
  final String id;
  final String kodeToken;
  final String namaSesi;
  final int? tingkatKelas;
  final int? semester;
  final int jumlahSoal;

  const PaketUjianInfo({
    required this.id,
    required this.kodeToken,
    required this.namaSesi,
    this.tingkatKelas,
    this.semester,
    required this.jumlahSoal,
  });

  factory PaketUjianInfo.fromJson(Map<String, dynamic> json) {
    return PaketUjianInfo(
      id: json['id']?.toString() ?? '',
      kodeToken: json['kode_token']?.toString() ?? '',
      namaSesi: json['nama_sesi']?.toString() ?? '',
      tingkatKelas: int.tryParse(json['tingkat_kelas']?.toString() ?? ''),
      semester: int.tryParse(json['semester']?.toString() ?? ''),
      jumlahSoal: int.tryParse(json['jumlah_soal']?.toString() ?? '') ?? 0,
    );
  }
}

/// Summary statistics in Rekap Nilai response
class StatistikRekap {
  final int totalPemain;
  final double rerataNilai;
  final double nilaiTertinggi;
  final double nilaiTerendah;
  final int kkm;
  final int tuntas;
  final int belumTuntas;

  const StatistikRekap({
    required this.totalPemain,
    required this.rerataNilai,
    required this.nilaiTertinggi,
    required this.nilaiTerendah,
    required this.kkm,
    required this.tuntas,
    required this.belumTuntas,
  });

  factory StatistikRekap.fromJson(Map<String, dynamic> json) {
    return StatistikRekap(
      totalPemain: int.tryParse(json['total_pemain']?.toString() ?? '') ?? 0,
      rerataNilai: double.tryParse(json['rerata_nilai']?.toString() ?? '') ?? 0.0,
      nilaiTertinggi: double.tryParse(json['nilai_tertinggi']?.toString() ?? '') ?? 0.0,
      nilaiTerendah: double.tryParse(json['nilai_terendah']?.toString() ?? '') ?? 0.0,
      kkm: int.tryParse(json['kkm']?.toString() ?? '') ?? 70,
      tuntas: int.tryParse(json['tuntas']?.toString() ?? '') ?? 0,
      belumTuntas: int.tryParse(json['belum_tuntas']?.toString() ?? '') ?? 0,
    );
  }
}

/// Item per siswa in leaderboard / nilai list
class NilaiSiswaItem {
  final int peringkat;
  final String namaPemain;
  final String nis;
  final double nilai;
  final int totalBenar;
  final int totalSalah;
  final bool tuntas;
  final String? dimainkanAt;

  const NilaiSiswaItem({
    required this.peringkat,
    required this.namaPemain,
    required this.nis,
    required this.nilai,
    required this.totalBenar,
    required this.totalSalah,
    required this.tuntas,
    this.dimainkanAt,
  });

  factory NilaiSiswaItem.fromJson(Map<String, dynamic> json) {
    return NilaiSiswaItem(
      peringkat: int.tryParse(json['peringkat']?.toString() ?? '') ?? 1,
      namaPemain: json['nama_pemain']?.toString() ?? '',
      nis: json['nis']?.toString() ?? '',
      nilai: double.tryParse(json['nilai']?.toString() ?? '') ?? 0.0,
      totalBenar: int.tryParse(json['total_benar']?.toString() ?? '') ?? 0,
      totalSalah: int.tryParse(json['total_salah']?.toString() ?? '') ?? 0,
      tuntas: json['tuntas'] == true || json['tuntas'] == 1,
      dimainkanAt: json['dimainkan_at']?.toString(),
    );
  }
}

/// Wrapper for complete Rekap Nilai data
class RekapNilaiData {
  final PaketUjianInfo paket;
  final StatistikRekap rekap;
  final List<NilaiSiswaItem> nilai;

  const RekapNilaiData({
    required this.paket,
    required this.rekap,
    required this.nilai,
  });

  factory RekapNilaiData.fromJson(Map<String, dynamic> json) {
    final paketMap = json['paket'] is Map<String, dynamic>
        ? json['paket'] as Map<String, dynamic>
        : <String, dynamic>{};
    final rekapMap = json['rekap'] is Map<String, dynamic>
        ? json['rekap'] as Map<String, dynamic>
        : <String, dynamic>{};
    final nilaiRaw = json['nilai'];
    List<NilaiSiswaItem> nilaiList = [];
    if (nilaiRaw is List) {
      nilaiList = nilaiRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => NilaiSiswaItem.fromJson(e))
          .toList();
    }

    return RekapNilaiData(
      paket: PaketUjianInfo.fromJson(paketMap),
      rekap: StatistikRekap.fromJson(rekapMap),
      nilai: nilaiList,
    );
  }
}
