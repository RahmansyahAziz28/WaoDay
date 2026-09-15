class UserModel {
  final String id;
  final String email;
  final String role;
  final String? name;
  final String? profilId;
  final dynamic sekolah;
  final Map<String, dynamic>? profil;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.profilId,
    this.sekolah,
    this.profil,
  });

  String get namaSekolah {
    if (sekolah is Map) {
      return (sekolah as Map)['nama_sekolah']?.toString() ?? '';
    }
    if (sekolah is String) return sekolah as String;
    return '';
  }

  String get sekolahId {
    if (sekolah is Map) {
      return (sekolah as Map)['id']?.toString() ?? '';
    }
    if (profil != null && profil!['sekolah_id'] != null) {
      return profil!['sekolah_id'].toString();
    }
    return '';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profilMap = json['profil'] is Map
        ? Map<String, dynamic>.from(json['profil'] as Map)
        : null;

    final resolvedName = json['name']?.toString() ??
        profilMap?['nama_admin']?.toString() ??
        profilMap?['nama_guru']?.toString() ??
        profilMap?['nama']?.toString() ??
        (json['user_metadata'] is Map ? (json['user_metadata']['name']?.toString()) : null);

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      name: resolvedName,
      profilId: profilMap?['id']?.toString(),
      sekolah: profilMap?['sekolah'],
      profil: profilMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    if (name != null) 'name': name,
    if (profilId != null) 'profil_id': profilId,
    if (sekolah != null) 'sekolah': sekolah,
    if (profil != null) 'profil': profil,
  };
}

class AuthData {
  final String token;
  final String? refreshToken;
  final int? expiresIn;
  final int? expiresAt;
  final UserModel user;

  const AuthData({
    required this.token,
    this.refreshToken,
    this.expiresIn,
    this.expiresAt,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString(),
      expiresIn: int.tryParse(json['expires_in']?.toString() ?? ''),
      expiresAt: int.tryParse(json['expires_at']?.toString() ?? ''),
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : (json['user'] is Map
              ? UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map))
              : const UserModel(id: '', email: '', role: '')),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    if (refreshToken != null) 'refresh_token': refreshToken,
    if (expiresIn != null) 'expires_in': expiresIn,
    if (expiresAt != null) 'expires_at': expiresAt,
    'user': user.toJson(),
  };
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : null,
    );
  }
}
