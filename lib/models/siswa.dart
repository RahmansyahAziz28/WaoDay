/// A student record.
class Siswa {
  const Siswa({
    required this.id,
    required this.nama,
    required this.nis,
    required this.sekolah,
    required this.kelas,
    this.kelasId,
    this.siswaId,
    this.sekolahId,
    this.pivotId,
  });

  final String id;
  final String nama;
  final String nis;
  final String sekolah;
  final String kelas;
  final String? kelasId;
  final String? siswaId;
  final String? sekolahId;
  final String? pivotId;

  factory Siswa.fromJson(Map<String, dynamic> json) {
    final siswaObj = json['siswa'] is Map<String, dynamic>
        ? json['siswa'] as Map<String, dynamic>
        : null;

    final sekolahData = siswaObj != null ? siswaObj['sekolah'] : json['sekolah'];
    String parsedSekolah = '';
    String? parsedSekolahId;
    if (sekolahData is Map<String, dynamic>) {
      parsedSekolah = sekolahData['nama_sekolah']?.toString() ??
          sekolahData['nama']?.toString() ??
          '';
      parsedSekolahId = sekolahData['id']?.toString();
    } else if (sekolahData != null) {
      parsedSekolah = sekolahData.toString();
    } else if (json['nama_sekolah'] != null) {
      parsedSekolah = json['nama_sekolah'].toString();
    }

    final String studentId = siswaObj?['id']?.toString() ??
        json['siswa_id']?.toString() ??
        json['id']?.toString() ??
        '';

    final String studentName = siswaObj?['nama_siswa']?.toString() ??
        siswaObj?['nama']?.toString() ??
        json['nama_siswa']?.toString() ??
        json['nama']?.toString() ??
        '';

    final String studentNis = siswaObj?['nis']?.toString() ??
        json['nis']?.toString() ??
        '';

    final String kelasStr = json['kode_kelas']?.toString() ??
        json['nama_kelas']?.toString() ??
        json['kelas']?.toString() ??
        '';

    return Siswa(
      id: studentId,
      nama: studentName,
      nis: studentNis,
      sekolah: parsedSekolah,
      kelas: kelasStr,
      kelasId: json['kelas_id']?.toString(),
      siswaId: json['siswa_id']?.toString() ?? studentId,
      sekolahId: parsedSekolahId ?? json['sekolah_id']?.toString(),
      pivotId: json.containsKey('siswa_id') ? json['id']?.toString() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama_siswa': nama,
        'nis': nis,
        'nama_sekolah': sekolah,
        'kode_kelas': kelas,
        if (sekolahId != null) 'sekolah_id': sekolahId,
        if (kelasId != null) 'kelas_id': kelasId,
        if (siswaId != null) 'siswa_id': siswaId,
      };
}
