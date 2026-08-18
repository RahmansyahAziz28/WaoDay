import 'package:flutter/foundation.dart';

import '../models/models.dart';

enum UserRole { guru }

class AppData extends ChangeNotifier {
  AppData._internal() {
    _seed();
  }

  static final AppData instance = AppData._internal();

  final List<Sekolah> sekolahList = [];
  final List<Siswa> siswaList = [];
  final List<Guru> guruList = [];
  final List<Kelas> kelasList = [];

  String? token;
  UserModel? currentUser;
  UserRole? currentRole;
  Guru? currentGuru;

  GuruDashboardData? guruDashboardData;
  bool isLoadingGuruDashboard = false;
  String? guruDashboardError;

  void _seed() {
    sekolahList.addAll(const [
      Sekolah(id: 'sk1', nama: 'SMA Negeri 1 Malang'),
      Sekolah(id: 'sk2', nama: 'SMK Negeri 1 Kepanjen'),
      Sekolah(id: 'sk3', nama: 'SMA Negeri 2 Malang'),
    ]);

    siswaList.addAll(const [
      Siswa(id: 'sw1', nama: 'Andi Pratama', nis: '102938', sekolah: 'SMA Negeri 1 Malang', kelas: 'XI IPA 1'),
      Siswa(id: 'sw2', nama: 'Budi Santoso', nis: '102939', sekolah: 'SMK Negeri 1 Kepanjen', kelas: 'XII RPL 1'),
      Siswa(id: 'sw3', nama: 'Citra Lestari', nis: '102940', sekolah: 'SMA Negeri 1 Malang', kelas: 'XI IPA 2'),
      Siswa(id: 'sw4', nama: 'Dimas Ramadhan', nis: '102941', sekolah: 'SMA Negeri 2 Malang', kelas: 'X IPS 1'),
    ]);

    guruList.addAll(const [
      Guru(id: 'gr1', nama: 'Siti Aisyah', nim: '198234', sekolah: 'SMA Negeri 1 Malang', kodeKelas: 'XIPA1'),
      Guru(id: 'gr2', nama: 'Budi Santoso', nim: '198235', sekolah: 'SMK Negeri 1 Kepanjen', kodeKelas: 'XI-RPL1'),
      Guru(id: 'gr3', nama: 'Rina Wulandari', nim: '198236', sekolah: 'SMA Negeri 2 Malang', kodeKelas: 'XIPS1'),
    ]);

    kelasList.addAll([
      Kelas(
        id: 'kl1',
        kodeKelas: 'XIPA1',
        namaKelas: 'XI IPA 1',
        sekolah: 'SMA Negeri 1 Malang',
        guruPengampu: 'Siti Aisyah',
        jumlahSiswa: 28,
        daftarSiswa: [siswaList[0]],
      ),
      Kelas(
        id: 'kl2',
        kodeKelas: 'XIPA2',
        namaKelas: 'XI IPA 2',
        sekolah: 'SMA Negeri 1 Malang',
        guruPengampu: 'Budi Santoso',
        jumlahSiswa: 26,
        daftarSiswa: [siswaList[2]],
      ),
      Kelas(
        id: 'kl3',
        kodeKelas: 'XII-RPL1',
        namaKelas: 'XII RPL 1',
        sekolah: 'SMK Negeri 1 Kepanjen',
        guruPengampu: 'Budi Santoso',
        jumlahSiswa: 32,
        daftarSiswa: [siswaList[1]],
      ),
    ]);
  }

  void setAuthData(AuthData authData) {
    token = authData.token;
    currentUser = authData.user;
    currentRole = UserRole.guru;

    final name = authData.user.name ?? authData.user.email.split('@').first;
    currentGuru = Guru(
      id: authData.user.id,
      nama: name,
      nim: '198235',
      sekolah: 'SMA Negeri 1 Malang',
      kodeKelas: 'XIPA1',
    );
    notifyListeners();
  }

  void loginAs(UserRole role) {
    currentRole = UserRole.guru;
    currentGuru = guruList[1];
    notifyListeners();
  }

  void setGuruDashboardData(GuruDashboardData data) {
    guruDashboardData = data;
    guruDashboardError = null;

    final profil = data.profil;
    final sekolahName = profil.sekolah?.namaSekolah ?? 'SMA';
    final primaryKodeKelas = data.kelas.isNotEmpty ? data.kelas.first.kodeKelas : '-';

    currentGuru = Guru(
      id: profil.id.isNotEmpty ? profil.id : (currentUser?.id ?? ''),
      nama: profil.namaGuru.isNotEmpty ? profil.namaGuru : (currentUser?.email ?? 'Guru'),
      nim: profil.nim.isNotEmpty ? profil.nim : '-',
      sekolah: sekolahName,
      kodeKelas: primaryKodeKelas,
    );

    if (data.kelas.isNotEmpty) {
      kelasList.removeWhere((k) => k.guruPengampu == currentGuru!.nama || data.kelas.any((dk) => dk.id == k.id));
      for (final k in data.kelas) {
        kelasList.add(
          Kelas(
            id: k.id,
            kodeKelas: k.kodeKelas,
            namaKelas: k.namaKelas,
            sekolah: sekolahName,
            guruPengampu: currentGuru!.nama,
            jumlahSiswa: 0,
            daftarSiswa: const [],
          ),
        );
      }
    }

    notifyListeners();
  }

  void clearAuth() {
    token = null;
    currentUser = null;
    currentRole = null;
    currentGuru = null;
    guruDashboardData = null;
    guruDashboardError = null;
    isLoadingGuruDashboard = false;
    notifyListeners();
  }

  void logout() {
    clearAuth();
  }

  List<Kelas> kelasForCurrentGuru() {
    final guru = currentGuru;
    if (guru == null) return const [];
    return kelasList.where((k) => k.guruPengampu == guru.nama).toList();
  }

  void deleteSiswa(String id) {
    siswaList.removeWhere((s) => s.id == id);
    for (final k in kelasList) {
      k.daftarSiswa.removeWhere((s) => s.id == id);
    }
    notifyListeners();
  }
}
