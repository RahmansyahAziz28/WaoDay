import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'manajemen_guru_screen.dart';
import 'manajemen_sekolah_screen.dart';
import 'profil_admin_screen.dart';

/// Bottom-navigation shell for the Administrator role.
class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  static const routeName = '/admin';

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;

  void _navigateToTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      AdminDashboardScreen(
        onNavigateToSekolah: () => _navigateToTab(1),
        onNavigateToGuru: () => _navigateToTab(2),
      ),
      const ManajemenSekolahScreen(),
      const ManajemenGuruScreen(),
      const ProfilAdminScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment_outlined),
            activeIcon: Icon(Icons.apartment_rounded),
            label: 'Sekolah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people_alt_rounded),
            label: 'Guru',
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
