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
  });

  final String id;
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

    return Kelas(
      id: json['id']?.toString() ?? '',
      kodeKelas: json['kode_kelas']?.toString() ?? '',
      namaKelas: json['nama_kelas']?.toString() ?? '',
      sekolah: sekolahMap?['nama_sekolah']?.toString() ??
          json['nama_sekolah']?.toString() ?? '',
      guruPengampu: guruMap?['nama_guru']?.toString() ??
          json['nama_guru']?.toString() ?? '',
      jumlahSiswa: siswaList.length,
      daftarSiswa: siswaList,
      sekolahId: sekolahMap?['id']?.toString() ?? json['sekolah_id']?.toString(),
      guruId: guruMap?['id']?.toString() ?? json['guru_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kode_kelas': kodeKelas,
        'nama_kelas': namaKelas,
        if (sekolahId != null) 'sekolah_id': sekolahId,
        if (guruId != null) 'guru_id': guruId,
      };
}
