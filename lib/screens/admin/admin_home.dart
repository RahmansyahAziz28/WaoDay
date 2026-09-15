import 'package:flutter/material.dart';

import '../../theme.dart';
import 'manajemen_guru_screen.dart';
import 'manajemen_kelas_screen.dart';
import 'profil_admin_screen.dart';

/// Screen shell for the Administrator role.
/// Provides tab navigation between Manajemen Guru, Manajemen Kelas, and Profil Admin.
class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  static const routeName = '/admin';

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ManajemenGuruScreen(),
    ManajemenKelasScreen(),
    ProfilAdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentIndex = idx);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded, color: AppColors.primary),
            label: 'Guru',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_rounded, color: AppColors.primary),
            label: 'Kelas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
