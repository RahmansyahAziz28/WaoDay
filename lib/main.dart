import 'package:flutter/material.dart';

import 'screens/admin/admin_home.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/guru/guru_home.dart';
import 'screens/superadmin/superadmin_home.dart';
import 'services/navigation_service.dart';
import 'theme.dart';

void main() {
  runApp(const AkademikApp());
}

class AkademikApp extends StatelessWidget {
  const AkademikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akademik',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: appMessengerKey,
      theme: AppTheme.light,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
        GuruHome.routeName: (context) => const GuruHome(),
        AdminHome.routeName: (context) => const AdminHome(),
        SuperAdminHome.routeName: (context) => const SuperAdminHome(),
      },
    );
  }
}
