/// Data model representing a materi bab item from GET /api/materi
class MateriBab {
  final String id;
  final int? tingkatKelas;
  final int? semester;
  final String? mataPelajaran;
  final dynamic nomorBab;
  final String judulBab;
  final String? subBab;
  final String? deskripsi;
  final int? urutan;
  final int totalSoal;

  const MateriBab({
    required this.id,
    this.tingkatKelas,
    this.semester,
    this.mataPelajaran,
    this.nomorBab,
    required this.judulBab,
    this.subBab,
    this.deskripsi,
    this.urutan,
    this.totalSoal = 0,
  });

  factory MateriBab.fromJson(Map<String, dynamic> json) {
    int totalSoalParsed = 0;
    if (json.containsKey('total_soal')) {
      totalSoalParsed = int.tryParse(json['total_soal']?.toString() ?? '') ?? 0;
    } else if (json['bank_soal'] is List && (json['bank_soal'] as List).isNotEmpty) {
      final first = (json['bank_soal'] as List).first;
      if (first is Map && first.containsKey('count')) {
        totalSoalParsed = int.tryParse(first['count']?.toString() ?? '') ?? 0;
      }
    }

    return MateriBab(
      id: json['id']?.toString() ?? '',
      tingkatKelas: int.tryParse(json['tingkat_kelas']?.toString() ?? ''),
      semester: int.tryParse(json['semester']?.toString() ?? ''),
      mataPelajaran: json['mata_pelajaran']?.toString(),
      nomorBab: json['nomor_bab'],
      judulBab: json['judul_bab']?.toString() ?? '',
      subBab: json['sub_bab']?.toString(),
      deskripsi: json['deskripsi']?.toString(),
      urutan: int.tryParse(json['urutan']?.toString() ?? ''),
      totalSoal: totalSoalParsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (tingkatKelas != null) 'tingkat_kelas': tingkatKelas,
        if (semester != null) 'semester': semester,
        if (mataPelajaran != null) 'mata_pelajaran': mataPelajaran,
        if (nomorBab != null) 'nomor_bab': nomorBab,
        'judul_bab': judulBab,
        if (subBab != null) 'sub_bab': subBab,
        if (deskripsi != null) 'deskripsi': deskripsi,
        if (urutan != null) 'urutan': urutan,
        'total_soal': totalSoal,
      };
}
