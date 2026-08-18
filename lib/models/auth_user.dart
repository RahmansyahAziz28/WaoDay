class UserModel {
  final String id;
  final String email;
  final String role;
  final String? name;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      name: json['name']?.toString() ?? (json['user_metadata'] is Map ? (json['user_metadata']['name']?.toString()) : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    if (name != null) 'name': name,
  };
}

class AuthData {
  final String token;
  final String? refreshToken;
  final UserModel user;

  const AuthData({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString(),
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : const UserModel(id: '', email: '', role: ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    if (refreshToken != null) 'refresh_token': refreshToken,
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
