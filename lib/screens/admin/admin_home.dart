import 'package:flutter/material.dart';

import 'manajemen_guru_screen.dart';

/// Screen shell for the Administrator role.
/// Focused exclusively on Guru CRUD management with top-right logout action.
class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  static const routeName = '/admin';

  @override
  Widget build(BuildContext context) {
    return const ManajemenGuruScreen();
  }
}
