// Model data untuk Rekap Nilai per Sub-Bab dan Rapor Siswa

class KelasBriefInfo {
  final String id;
  final String kodeKelas;
  final String namaKelas;
  final int tingkat;
  final String sekolah;
  final String guru;

  const KelasBriefInfo({
    required this.id,
    required this.kodeKelas,
    required this.namaKelas,
    this.tingkat = 0,
    this.sekolah = '',
    this.guru = '',
  });

  factory KelasBriefInfo.fromJson(Map<String, dynamic> json) {
    return KelasBriefInfo(
      id: json['id']?.toString() ?? '',
      kodeKelas: json['kode_kelas']?.toString() ?? '',
      namaKelas: json['nama_kelas']?.toString() ?? '',
      tingkat: int.tryParse(json['tingkat']?.toString() ?? '') ?? 0,
      sekolah: json['sekolah']?.toString() ?? '',
      guru: json['guru']?.toString() ?? '',
    );
  }
}

class RekapKelasSummary {
  final int totalSiswaKelas;
  final int totalSiswaMengerjakan;
  final int belumMengerjakan;
  final double rerataKelas;
  final double nilaiTertinggi;
  final double nilaiTerendah;
  final int tuntas;
  final int belumTuntas;

  const RekapKelasSummary({
    this.totalSiswaKelas = 0,
    this.totalSiswaMengerjakan = 0,
    this.belumMengerjakan = 0,
    this.rerataKelas = 0.0,
    this.nilaiTertinggi = 0.0,
    this.nilaiTerendah = 0.0,
    this.tuntas = 0,
    this.belumTuntas = 0,
  });

  factory RekapKelasSummary.fromJson(Map<String, dynamic> json) {
    return RekapKelasSummary(
      totalSiswaKelas:
          int.tryParse(json['total_siswa_kelas']?.toString() ?? '') ?? 0,
      totalSiswaMengerjakan:
          int.tryParse(json['total_siswa_mengerjakan']?.toString() ?? '') ?? 0,
      belumMengerjakan:
          int.tryParse(json['belum_mengerjakan']?.toString() ?? '') ?? 0,
      rerataKelas:
          num.tryParse(json['rerata_kelas']?.toString() ?? '')?.toDouble() ?? 0.0,
      nilaiTertinggi:
          num.tryParse(json['nilai_tertinggi']?.toString() ?? '')?.toDouble() ??
              0.0,
      nilaiTerendah:
          num.tryParse(json['nilai_terendah']?.toString() ?? '')?.toDouble() ??
              0.0,
      tuntas: int.tryParse(json['tuntas']?.toString() ?? '') ?? 0,
      belumTuntas:
          int.tryParse(json['belum_tuntas']?.toString() ?? '') ?? 0,
    );
  }
}

class SubBabInfo {
  final String id;
  final String nomorBab;
  final String judulBab;
  final String subBab;

  const SubBabInfo({
    required this.id,
    required this.nomorBab,
    required this.judulBab,
    required this.subBab,
  });

  factory SubBabInfo.fromJson(Map<String, dynamic> json) {
    return SubBabInfo(
      id: json['id']?.toString() ?? '',
      nomorBab: json['nomor_bab']?.toString() ?? '',
      judulBab: json['judul_bab']?.toString() ?? '',
      subBab: json['sub_bab']?.toString() ?? '',
    );
  }
}

class NilaiSubBabDetail {
  final int benar;
  final int total;
  final double nilai;
  final bool tuntas;

  const NilaiSubBabDetail({
    this.benar = 0,
    this.total = 0,
    this.nilai = 0.0,
    this.tuntas = false,
  });

  factory NilaiSubBabDetail.fromJson(Map<String, dynamic> json) {
    return NilaiSubBabDetail(
      benar: int.tryParse(json['benar']?.toString() ?? '') ?? 0,
      total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
      nilai: num.tryParse(json['nilai']?.toString() ?? '')?.toDouble() ?? 0.0,
      tuntas: json['tuntas'] == true || json['tuntas'] == 1,
    );
  }
}

class SiswaNilaiSubBabItem {
  final String siswaId;
  final String nis;
  final String namaSiswa;
  final int totalSesi;
  final int totalSoal;
  final int totalBenar;
  final double rerataNilai;
  final String statusKkm;
  final int skorGameTertinggi;
  final int totalKoin;
  final int jarakTerjauhMeter;
  final String? terakhirMengerjakan;
  final Map<String, NilaiSubBabDetail> nilaiSubBab;

  const SiswaNilaiSubBabItem({
    required this.siswaId,
    required this.nis,
    required this.namaSiswa,
    this.totalSesi = 0,
    this.totalSoal = 0,
    this.totalBenar = 0,
    this.rerataNilai = 0.0,
    this.statusKkm = '',
    this.skorGameTertinggi = 0,
    this.totalKoin = 0,
    this.jarakTerjauhMeter = 0,
    this.terakhirMengerjakan,
    this.nilaiSubBab = const {},
  });

  factory SiswaNilaiSubBabItem.fromJson(Map<String, dynamic> json) {
    final Map<String, NilaiSubBabDetail> map = {};
    if (json['nilai_sub_bab'] is Map) {
      final rawMap = json['nilai_sub_bab'] as Map;
      rawMap.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          map[k.toString()] = NilaiSubBabDetail.fromJson(v);
        } else if (v is Map) {
          map[k.toString()] =
              NilaiSubBabDetail.fromJson(Map<String, dynamic>.from(v));
        }
      });
    }

    return SiswaNilaiSubBabItem(
      siswaId: json['siswa_id']?.toString() ?? '',
      nis: json['nis']?.toString() ?? '',
      namaSiswa: json['nama_siswa']?.toString() ?? '',
      totalSesi: int.tryParse(json['total_sesi']?.toString() ?? '') ?? 0,
      totalSoal: int.tryParse(json['total_soal']?.toString() ?? '') ?? 0,
      totalBenar: int.tryParse(json['total_benar']?.toString() ?? '') ?? 0,
      rerataNilai:
          num.tryParse(json['rerata_nilai']?.toString() ?? '')?.toDouble() ?? 0.0,
      statusKkm: json['status_kkm']?.toString() ?? 'Belum Mengerjakan',
      skorGameTertinggi:
          int.tryParse(json['skor_game_tertinggi']?.toString() ?? '') ?? 0,
      totalKoin: int.tryParse(json['total_koin']?.toString() ?? '') ?? 0,
      jarakTerjauhMeter:
          int.tryParse(json['jarak_terjauh_meter']?.toString() ?? '') ?? 0,
      terakhirMengerjakan: json['terakhir_mengerjakan']?.toString(),
      nilaiSubBab: map,
    );
  }
}

class RekapNilaiKelasResponse {
  final bool success;
  final KelasBriefInfo? kelas;
  final int kkm;
  final RekapKelasSummary rekapKelas;
  final List<SubBabInfo> subBabs;
  final List<SiswaNilaiSubBabItem> data;
  final String? message;

  const RekapNilaiKelasResponse({
    required this.success,
    this.kelas,
    this.kkm = 70,
    required this.rekapKelas,
    this.subBabs = const [],
    this.data = const [],
    this.message,
  });

  factory RekapNilaiKelasResponse.fromJson(Map<String, dynamic> json) {
    List<SubBabInfo> subBabsList = [];
    if (json['sub_babs'] is List) {
      subBabsList = (json['sub_babs'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => SubBabInfo.fromJson(e))
          .toList();
    }

    List<SiswaNilaiSubBabItem> dataList = [];
    if (json['data'] is List) {
      dataList = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => SiswaNilaiSubBabItem.fromJson(e))
          .toList();
    }

    return RekapNilaiKelasResponse(
      success: json['success'] == true,
      kelas: json['kelas'] is Map<String, dynamic>
          ? KelasBriefInfo.fromJson(json['kelas'] as Map<String, dynamic>)
          : null,
      kkm: int.tryParse(json['kkm']?.toString() ?? '') ?? 70,
      rekapKelas: json['rekap_kelas'] is Map<String, dynamic>
          ? RekapKelasSummary.fromJson(
              json['rekap_kelas'] as Map<String, dynamic>)
          : const RekapKelasSummary(),
      subBabs: subBabsList,
      data: dataList,
      message: json['message']?.toString(),
    );
  }
}

// ── Models Rapor Nilai per Siswa ─────────────────────────────────────────────

class SiswaRaporKelasInfo {
  final String id;
  final String kodeKelas;
  final String namaKelas;

  const SiswaRaporKelasInfo({
    required this.id,
    required this.kodeKelas,
    required this.namaKelas,
  });

  factory SiswaRaporKelasInfo.fromJson(Map<String, dynamic> json) {
    return SiswaRaporKelasInfo(
      id: json['id']?.toString() ?? '',
      kodeKelas: json['kode_kelas']?.toString() ?? '',
      namaKelas: json['nama_kelas']?.toString() ?? '',
    );
  }
}

class SiswaRaporInfo {
  final String id;
  final String nis;
  final String namaSiswa;
  final String sekolah;
  final List<SiswaRaporKelasInfo> kelas;

  const SiswaRaporInfo({
    required this.id,
    required this.nis,
    required this.namaSiswa,
    this.sekolah = '',
    this.kelas = const [],
  });

  factory SiswaRaporInfo.fromJson(Map<String, dynamic> json) {
    List<SiswaRaporKelasInfo> kelasList = [];
    if (json['kelas'] is List) {
      kelasList = (json['kelas'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => SiswaRaporKelasInfo.fromJson(e))
          .toList();
    }

    return SiswaRaporInfo(
      id: json['id']?.toString() ?? '',
      nis: json['nis']?.toString() ?? '',
      namaSiswa: json['nama_siswa']?.toString() ?? '',
      sekolah: json['sekolah']?.toString() ?? '',
      kelas: kelasList,
    );
  }
}

class RaporRingkasan {
  final int totalSesi;
  final int totalSoalDikerjakan;
  final int totalBenar;
  final double rerataNilai;
  final int subBabTuntas;
  final int subBabRemedial;

  const RaporRingkasan({
    this.totalSesi = 0,
    this.totalSoalDikerjakan = 0,
    this.totalBenar = 0,
    this.rerataNilai = 0.0,
    this.subBabTuntas = 0,
    this.subBabRemedial = 0,
  });

  factory RaporRingkasan.fromJson(Map<String, dynamic> json) {
    return RaporRingkasan(
      totalSesi: int.tryParse(json['total_sesi']?.toString() ?? '') ?? 0,
      totalSoalDikerjakan:
          int.tryParse(json['total_soal_dikerjakan']?.toString() ?? '') ?? 0,
      totalBenar: int.tryParse(json['total_benar']?.toString() ?? '') ?? 0,
      rerataNilai:
          num.tryParse(json['rerata_nilai']?.toString() ?? '')?.toDouble() ?? 0.0,
      subBabTuntas: int.tryParse(json['sub_bab_tuntas']?.toString() ?? '') ?? 0,
      subBabRemedial:
          int.tryParse(json['sub_bab_remedial']?.toString() ?? '') ?? 0,
    );
  }
}

class SubBabRaporDetail {
  final String id;
  final String nomorBab;
  final String judulBab;
  final String subBab;
  final int tingkatKelas;
  final int semester;
  final int totalSoal;
  final int totalBenar;
  final double nilai;
  final String statusKkm;

  const SubBabRaporDetail({
    required this.id,
    required this.nomorBab,
    required this.judulBab,
    required this.subBab,
    this.tingkatKelas = 0,
    this.semester = 1,
    this.totalSoal = 0,
    this.totalBenar = 0,
    this.nilai = 0.0,
    this.statusKkm = '',
  });

  factory SubBabRaporDetail.fromJson(Map<String, dynamic> json) {
    return SubBabRaporDetail(
      id: json['id']?.toString() ?? '',
      nomorBab: json['nomor_bab']?.toString() ?? '',
      judulBab: json['judul_bab']?.toString() ?? '',
      subBab: json['sub_bab']?.toString() ?? '',
      tingkatKelas:
          int.tryParse(json['tingkat_kelas']?.toString() ?? '') ?? 0,
      semester: int.tryParse(json['semester']?.toString() ?? '') ?? 1,
      totalSoal: int.tryParse(json['total_soal']?.toString() ?? '') ?? 0,
      totalBenar: int.tryParse(json['total_benar']?.toString() ?? '') ?? 0,
      nilai: num.tryParse(json['nilai']?.toString() ?? '')?.toDouble() ?? 0.0,
      statusKkm: json['status_kkm']?.toString() ?? 'Remedial',
    );
  }
}

class RiwayatSesiItem {
  final String id;
  final String kodeToken;
  final String namaSesi;
  final int totalSoal;
  final int totalBenar;
  final double nilai;
  final int skorGame;
  final int koin;
  final int jarakMeter;
  final String? dimainkanAt;
  final String statusKkm;

  const RiwayatSesiItem({
    required this.id,
    required this.kodeToken,
    required this.namaSesi,
    this.totalSoal = 0,
    this.totalBenar = 0,
    this.nilai = 0.0,
    this.skorGame = 0,
    this.koin = 0,
    this.jarakMeter = 0,
    this.dimainkanAt,
    this.statusKkm = '',
  });

  factory RiwayatSesiItem.fromJson(Map<String, dynamic> json) {
    return RiwayatSesiItem(
      id: json['id']?.toString() ?? '',
      kodeToken: json['kode_token']?.toString() ?? '',
      namaSesi: json['nama_sesi']?.toString() ?? '',
      totalSoal: int.tryParse(json['total_soal']?.toString() ?? '') ?? 0,
      totalBenar: int.tryParse(json['total_benar']?.toString() ?? '') ?? 0,
      nilai: num.tryParse(json['nilai']?.toString() ?? '')?.toDouble() ?? 0.0,
      skorGame: int.tryParse(json['skor_game']?.toString() ?? '') ?? 0,
      koin: int.tryParse(json['koin']?.toString() ?? '') ?? 0,
      jarakMeter: int.tryParse(json['jarak_meter']?.toString() ?? '') ?? 0,
      dimainkanAt: json['dimainkan_at']?.toString(),
      statusKkm: json['status_kkm']?.toString() ?? '',
    );
  }
}

class RaporNilaiSiswaResponse {
  final bool success;
  final SiswaRaporInfo? siswa;
  final int kkm;
  final RaporRingkasan ringkasan;
  final List<SubBabRaporDetail> subBabs;
  final List<RiwayatSesiItem> riwayatSesi;
  final String? message;

  const RaporNilaiSiswaResponse({
    required this.success,
    this.siswa,
    this.kkm = 70,
    required this.ringkasan,
    this.subBabs = const [],
    this.riwayatSesi = const [],
    this.message,
  });

  factory RaporNilaiSiswaResponse.fromJson(Map<String, dynamic> json) {
    List<SubBabRaporDetail> subBabsList = [];
    if (json['sub_babs'] is List) {
      subBabsList = (json['sub_babs'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => SubBabRaporDetail.fromJson(e))
          .toList();
    }

    List<RiwayatSesiItem> riwayatList = [];
    if (json['riwayat_sesi'] is List) {
      riwayatList = (json['riwayat_sesi'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => RiwayatSesiItem.fromJson(e))
          .toList();
    }

    return RaporNilaiSiswaResponse(
      success: json['success'] == true,
      siswa: json['siswa'] is Map<String, dynamic>
          ? SiswaRaporInfo.fromJson(json['siswa'] as Map<String, dynamic>)
          : null,
      kkm: int.tryParse(json['kkm']?.toString() ?? '') ?? 70,
      ringkasan: json['ringkasan'] is Map<String, dynamic>
          ? RaporRingkasan.fromJson(json['ringkasan'] as Map<String, dynamic>)
          : const RaporRingkasan(),
      subBabs: subBabsList,
      riwayatSesi: riwayatList,
      message: json['message']?.toString(),
    );
  }
}
