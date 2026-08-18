import 'package:flutter/material.dart';

import 'guru_dashboard_screen.dart';
import 'kelas_saya_screen.dart';
import 'profil_guru_screen.dart';

/// Bottom-navigation shell for the teacher (Guru) role.
class GuruHome extends StatefulWidget {
  const GuruHome({super.key});

  static const routeName = '/guru';

  @override
  State<GuruHome> createState() => _GuruHomeState();
}

class _GuruHomeState extends State<GuruHome> {
  int _index = 0;

  static const _screens = [
    GuruDashboardScreen(),
    KelasSayaScreen(),
    ProfilGuruScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_outlined),
            activeIcon: Icon(Icons.class_),
            label: 'Kelas Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
