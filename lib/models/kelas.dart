import 'siswa.dart';

/// A class (kelas) record, taught by one teacher at one school.
class Kelas {
  const Kelas({
    required this.id,
    required this.kodeKelas,
    required this.namaKelas,
    required this.sekolah,
    required this.guruPengampu,
    required this.jumlahSiswa,
    required this.daftarSiswa,
    this.sekolahId,
    this.guruId,
    this.tingkat = 10,
  });

  final String id;
  String get kelasId => id;
  final String kodeKelas;
  final String namaKelas;
  final String sekolah;
  final String guruPengampu;
  final int jumlahSiswa;
  final List<Siswa> daftarSiswa;
  /// Raw sekolah_id for API PUT requests.
  final String? sekolahId;
  /// Raw guru_id for API PUT requests.
  final String? guruId;
  /// Tingkat kelas (10, 11, or 12).
  final int tingkat;

  static int _extractTingkat(
    Map<String, dynamic> json,
    String namaKelas,
    String kodeKelas,
  ) {
    final raw = json['tingkat'] ?? json['tingkat_kelas'];
    if (raw != null) {
      final val = int.tryParse(raw.toString());
      if (val != null && (val == 10 || val == 11 || val == 12)) {
        return val;
      }
    }
    final combined = '$namaKelas $kodeKelas'.toUpperCase();
    if (RegExp(r'\b(XII|12)\b').hasMatch(combined)) return 12;
    if (RegExp(r'\b(XI|11)\b').hasMatch(combined)) return 11;
    if (RegExp(r'\b(X|10)\b').hasMatch(combined)) return 10;
    return 10;
  }

  factory Kelas.fromJson(Map<String, dynamic> json) {
    final List<Siswa> siswaList = json['siswa'] is List
        ? (json['siswa'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => Siswa.fromJson(e))
            .toList()
        : <Siswa>[];

    final sekolahMap = json['sekolah'] is Map<String, dynamic>
        ? json['sekolah'] as Map<String, dynamic>
        : null;

    final guruMap = json['guru'] is Map<String, dynamic>
        ? json['guru'] as Map<String, dynamic>
        : null;

    final namaKelas = json['nama_kelas']?.toString() ?? '';
    final kodeKelas = json['kode_kelas']?.toString() ?? '';
    final tingkat = _extractTingkat(json, namaKelas, kodeKelas);

    return Kelas(
      id: json['id']?.toString() ?? '',
      kodeKelas: kodeKelas,
      namaKelas: namaKelas,
      sekolah: sekolahMap?['nama_sekolah']?.toString() ??
          json['nama_sekolah']?.toString() ?? '',
      guruPengampu: guruMap?['nama_guru']?.toString() ??
          json['nama_guru']?.toString() ?? '',
      jumlahSiswa: siswaList.length,
      daftarSiswa: siswaList,
      sekolahId: sekolahMap?['id']?.toString() ?? json['sekolah_id']?.toString(),
      guruId: guruMap?['id']?.toString() ?? json['guru_id']?.toString(),
      tingkat: tingkat,
    );
  }

  Kelas copyWith({
    String? id,
    String? kodeKelas,
    String? namaKelas,
    String? sekolah,
    String? guruPengampu,
    int? jumlahSiswa,
    List<Siswa>? daftarSiswa,
    String? sekolahId,
    String? guruId,
    int? tingkat,
  }) {
    return Kelas(
      id: id ?? this.id,
      kodeKelas: kodeKelas ?? this.kodeKelas,
      namaKelas: namaKelas ?? this.namaKelas,
      sekolah: sekolah ?? this.sekolah,
      guruPengampu: guruPengampu ?? this.guruPengampu,
      jumlahSiswa: jumlahSiswa ?? this.jumlahSiswa,
      daftarSiswa: daftarSiswa ?? this.daftarSiswa,
      sekolahId: sekolahId ?? this.sekolahId,
      guruId: guruId ?? this.guruId,
      tingkat: tingkat ?? this.tingkat,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kode_kelas': kodeKelas,
        'nama_kelas': namaKelas,
        'tingkat': tingkat,
        if (sekolahId != null) 'sekolah_id': sekolahId,
        if (guruId != null) 'guru_id': guruId,
      };
}
