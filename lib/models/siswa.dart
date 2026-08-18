/// A student record.
class Siswa {
  const Siswa({
    required this.id,
    required this.nama,
    required this.nis,
    required this.sekolah,
    required this.kelas,
  });

  final String id;
  final String nama;
  final String nis;
  final String sekolah;
  final String kelas;

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id']?.toString() ?? '',
      nama: json['nama_siswa']?.toString() ?? json['nama']?.toString() ?? '',
      nis: json['nis']?.toString() ?? '',
      sekolah: json['nama_sekolah']?.toString() ?? json['sekolah']?.toString() ?? '',
      kelas: json['kode_kelas']?.toString() ?? json['kelas']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama_siswa': nama,
        'nis': nis,
        'nama_sekolah': sekolah,
        'kode_kelas': kelas,
      };
}
