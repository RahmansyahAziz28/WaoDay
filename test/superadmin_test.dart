import 'package:flutter_test/flutter_test.dart';
import 'package:waoday/data/dummy_data.dart';
import 'package:waoday/models/admin_sekolah.dart';
import 'package:waoday/models/auth_user.dart';
import 'package:waoday/models/sekolah.dart';
import 'package:waoday/services/admin_sekolah_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SuperAdmin Models & Role Tests', () {
    test('PaginatedSekolahResponse parses user payload correctly', () {
      final json = {
        'success': true,
        'count': 7,
        'data': [
          {
            'id': 'f0de24e9-e8b7-441c-9194-05ede36ba908',
            'nama_sekolah': 'SMA Negeri 1 Indonesia 4860',
            'alamat': 'Jl. Merdeka No. 45',
            'created_at': '2026-08-16T13:59:06.039554+00:00',
            'updated_at': '2026-08-16T13:59:06.039554+00:00',
          },
          {
            'id': '6e0ea52c-4b5a-4049-bcf3-be7872475ed3',
            'nama_sekolah': 'SMA Negeri 1 Indonesia 6226',
            'alamat': 'Jl. Merdeka No. 45',
            'created_at': '2026-08-16T13:58:47.614936+00:00',
            'updated_at': '2026-08-16T13:58:47.614936+00:00',
          },
        ],
      };

      final paginated = PaginatedSekolahResponse.fromJson(json, defaultPage: 1, defaultLimit: 20);
      expect(paginated.success, isTrue);
      expect(paginated.count, equals(7));
      expect(paginated.page, equals(1));
      expect(paginated.limit, equals(20));
      expect(paginated.data.length, equals(2));
      expect(paginated.data[0].id, equals('f0de24e9-e8b7-441c-9194-05ede36ba908'));
      expect(paginated.data[0].nama, equals('SMA Negeri 1 Indonesia 4860'));
      expect(paginated.data[0].alamat, equals('Jl. Merdeka No. 45'));
    });

    test('PaginatedAdminResponse parses GET admin response correctly', () {
      final json = {
        "success": true,
        "count": 1,
        "page": 1,
        "limit": 20,
        "totalPages": 1,
        "data": [
          {
            "id": "3c48c714-3ac7-41f5-998b-17dc93713ed2",
            "user_id": "e5880f78-0bce-449f-a747-55d5a5cd2591",
            "nama_admin": "Super Admin",
            "sekolah_id": null,
            "created_at": "2026-09-07T11:44:28.742032+00:00",
            "updated_at": "2026-09-07T11:44:28.742032+00:00",
            "sekolah": null,
            "email": "superadmin@gmail.com",
            "is_super_admin": true
          }
        ]
      };

      final paginated = PaginatedAdminResponse.fromJson(json);
      expect(paginated.success, isTrue);
      expect(paginated.count, equals(1));
      expect(paginated.page, equals(1));
      expect(paginated.limit, equals(20));
      expect(paginated.totalPages, equals(1));
      expect(paginated.data.length, equals(1));

      final admin = paginated.data.first;
      expect(admin.id, equals('3c48c714-3ac7-41f5-998b-17dc93713ed2'));
      expect(admin.userId, equals('e5880f78-0bce-449f-a747-55d5a5cd2591'));
      expect(admin.nama, equals('Super Admin'));
      expect(admin.email, equals('superadmin@gmail.com'));
      expect(admin.isSuperAdmin, isTrue);
      expect(admin.sekolahNama, equals('Pusat (Super Admin)'));
    });

    test('User login admin response payload parses properly', () {
      final json = {
        "success": true,
        "message": "Login berhasil sebagai super_admin",
        "data": {
          "token": "test-jwt-token",
          "refresh_token": "kbsc46l4tro6",
          "expires_in": 604800,
          "expires_at": 1789453527,
          "user": {
            "id": "e5880f78-0bce-449f-a747-55d5a5cd2591",
            "email": "superadmin@gmail.com",
            "role": "super_admin",
            "profil": {
              "id": "3c48c714-3ac7-41f5-998b-17dc93713ed2",
              "nama_admin": "Super Admin",
              "sekolah": null
            }
          }
        }
      };

      final authData = AuthData.fromJson(json['data'] as Map<String, dynamic>);
      expect(authData.token, equals('test-jwt-token'));
      expect(authData.refreshToken, equals('kbsc46l4tro6'));
      expect(authData.expiresIn, equals(604800));
      expect(authData.expiresAt, equals(1789453527));
      expect(authData.user.id, equals('e5880f78-0bce-449f-a747-55d5a5cd2591'));
      expect(authData.user.role, equals('super_admin'));
      expect(authData.user.name, equals('Super Admin'));
      expect(authData.user.profilId, equals('3c48c714-3ac7-41f5-998b-17dc93713ed2'));
    });

    test('AdminSekolah toCreateBody and toUpdateBody match Swagger spec', () {
      const admin = AdminSekolah(
        id: 'adm-test',
        nama: 'Budi Santoso',
        email: 'budi@sma1jakarta.sch.id',
        sekolahId: 'uuid-sekolah-disini',
        sekolahNama: 'SMA 1 Jakarta',
      );

      final createBody = admin.toCreateBody(password: 'Admin@2024');
      expect(createBody['nama_admin'], equals('Budi Santoso'));
      expect(createBody['sekolah_id'], equals('uuid-sekolah-disini'));
      expect(createBody['email'], equals('budi@sma1jakarta.sch.id'));
      expect(createBody['password'], equals('Admin@2024'));

      final updateBody = admin.toUpdateBody(password: 'Admin@2025');
      expect(updateBody['nama_admin'], equals('Budi Santoso'));
      expect(updateBody['sekolah_id'], equals('uuid-sekolah-disini'));
      expect(updateBody['password'], equals('Admin@2025'));
    });

    test('AppData sets role to superadmin properly', () {
      AppData.instance.setAuthData(
        const AuthData(
          token: 'token_sa',
          user: UserModel(id: 'sa1', email: 'super@admin.com', role: 'superadmin'),
        ),
      );
      expect(AppData.instance.currentRole, equals(UserRole.superadmin));

      AppData.instance.setAuthData(
        const AuthData(
          token: 'token_sa2',
          user: UserModel(id: 'sa2', email: 'super2@admin.com', role: 'super_admin'),
        ),
      );
      expect(AppData.instance.currentRole, equals(UserRole.superadmin));
      AppData.instance.clearAuth();
    });
  });

  group('AdminSekolahService CRUD Tests', () {
    final service = AdminSekolahService.instance;

    setUp(() {
      AppData.instance.clearAuth();
    });

    test('getAdminList returns seeded admins in unauthenticated mode', () async {
      final res = await service.getAdminList();
      expect(res.success, isTrue);
      expect(res.data, isNotNull);
      expect(res.data!.length, greaterThanOrEqualTo(3));
    });

    test('createAdmin, updateAdmin, deleteAdmin flow', () async {
      final createRes = await service.createAdmin(
        nama: 'Test Admin Baru',
        email: 'test.admin.baru@sekolah.sch.id',
        password: 'password123',
        sekolahId: 'sk-test-1',
        sekolahNama: 'SMA Test 1',
        telepon: '081122334455',
      );

      expect(createRes.success, isTrue);
      expect(createRes.data, isNotNull);
      final adminId = createRes.data!.id;

      // Update
      final updateRes = await service.updateAdmin(
        adminId,
        nama: 'Test Admin Diperbarui',
        email: 'test.admin.baru@sekolah.sch.id',
        sekolahId: 'sk-test-1',
        sekolahNama: 'SMA Test 1',
        isActive: false,
      );
      expect(updateRes.success, isTrue);
      expect(updateRes.data!.nama, equals('Test Admin Diperbarui'));
      expect(updateRes.data!.isActive, isFalse);

      // Delete
      final deleteRes = await service.deleteAdmin(adminId);
      expect(deleteRes.success, isTrue);

      final listAfter = await service.getAdminList();
      expect(listAfter.data!.any((a) => a.id == adminId), isFalse);
    });
  });
}
