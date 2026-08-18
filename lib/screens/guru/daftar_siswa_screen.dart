import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class DaftarSiswaScreen extends StatefulWidget {
  const DaftarSiswaScreen({super.key, this.kelas});

  final Kelas? kelas;

  @override
  State<DaftarSiswaScreen> createState() => _DaftarSiswaScreenState();
}

class _DaftarSiswaScreenState extends State<DaftarSiswaScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Siswa> _sourceList(AppData data) {
    if (widget.kelas != null) {
      return data.siswaList
          .where((s) => s.kelas == widget.kelas!.namaKelas && s.sekolah == widget.kelas!.sekolah)
          .toList();
    }
    return data.siswaList;
  }

  Future<void> _handleDelete(Siswa siswa) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Siswa',
      message: 'Yakin ingin menghapus ${siswa.nama} dari daftar? Tindakan ini tidak dapat dibatalkan.',
    );
    if (!confirmed) return;
    AppData.instance.deleteSiswa(siswa.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${siswa.nama} berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kelas != null ? 'Siswa ${widget.kelas!.namaKelas}' : 'Daftar Siswa'),
      ),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final all = _sourceList(AppData.instance);
          final filtered = _query.isEmpty
              ? all
              : all
                  .where((s) =>
                      s.nama.toLowerCase().contains(_query.toLowerCase()) || s.nis.contains(_query))
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: AppSearchBar(
                  controller: _searchController,
                  hint: 'Cari nama atau NIS...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: all.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline,
                        title: 'Belum ada siswa',
                        message: 'Data siswa akan muncul di sini.',
                      )
                    : filtered.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off,
                            title: 'Tidak ditemukan',
                            message: 'Coba kata kunci pencarian lain.',
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final s = filtered[index];
                              return AppCard(
                                child: Row(
                                  children: [
                                    AppAvatar(name: s.nama, size: 44),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.nama,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'NIS ${s.nis} · ${s.kelas}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                          Text(s.sekolah, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      onPressed: () => _handleDelete(s),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
