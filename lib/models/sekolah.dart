/// A school record.
///
/// Detailed school fields are not part of the current backend
/// requirements, so this model intentionally only carries a name.
class Sekolah {
  const Sekolah({
    required this.id,
    required this.nama,
  });

  final String id;
  final String nama;
}
