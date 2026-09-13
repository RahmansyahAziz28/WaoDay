import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waoday/data/dummy_data.dart';
import 'package:waoday/main.dart';
import 'package:waoday/models/auth_user.dart';
import 'package:waoday/screens/auth/login_screen.dart';
import 'package:waoday/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'dummy_jwt_token',
      'auth_refresh_token': 'dummy_refresh_token',
      'auth_user': '{"id":"u1","email":"test@sekolah.sch.id","role":"guru"}',
    });
    AppData.instance.setAuthData(
      const AuthData(
        token: 'dummy_jwt_token',
        refreshToken: 'dummy_refresh_token',
        user: UserModel(id: 'u1', email: 'test@sekolah.sch.id', role: 'guru'),
      ),
    );
  });

  testWidgets('handleSessionExpired clears auth, redirects to LoginScreen and shows notification', (tester) async {
    await tester.pumpWidget(const AkademikApp());
    await tester.pumpAndSettle();

    // Verify user initially has token
    expect(AppData.instance.token, equals('dummy_jwt_token'));

    // Trigger 401 session expired handling
    await AuthService.instance.handleSessionExpired();
    await tester.pumpAndSettle();

    // Verify token was cleared
    expect(AppData.instance.token, isNull);
    expect(AppData.instance.currentUser, isNull);

    // Verify redirected to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);

    // Verify session expired SnackBar notification is displayed
    expect(find.text('Sesi login telah berakhir. Silakan login kembali.'), findsOneWidget);

    // Advance remaining debounce and snackbar timers
    await tester.pump(const Duration(seconds: 5));
  });
}
