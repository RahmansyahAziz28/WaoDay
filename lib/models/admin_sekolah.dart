/// Model for School Administrator (Admin per Sekolah)
class AdminSekolah {
  final String id;
  final String? userId;
  final String nama;
  final String email;
  final String sekolahId;
  final String sekolahNama;
  final String? telepon;
  final bool isActive;
  final bool isSuperAdmin;
  final String? createdAt;
  final String? updatedAt;

  const AdminSekolah({
    required this.id,
    this.userId,
    required this.nama,
    required this.email,
    required this.sekolahId,
    required this.sekolahNama,
    this.telepon,
    this.isActive = true,
    this.isSuperAdmin = false,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminSekolah.fromJson(Map<String, dynamic> json) {
    final isSuperAdmin = json['is_super_admin'] == true ||
        json['role']?.toString().toLowerCase() == 'super_admin';

    String resolvedSekolahId = json['sekolah_id']?.toString() ?? json['sekolahId']?.toString() ?? '';
    String resolvedSekolahNama = json['sekolah_nama']?.toString() ?? json['nama_sekolah']?.toString() ?? '';

    if (json['sekolah'] is Map) {
      final s = json['sekolah'] as Map;
      if (resolvedSekolahId.isEmpty) {
        resolvedSekolahId = s['id']?.toString() ?? '';
      }
      if (resolvedSekolahNama.isEmpty) {
        resolvedSekolahNama = s['nama_sekolah']?.toString() ?? s['nama']?.toString() ?? '';
      }
    }

    if (resolvedSekolahNama.isEmpty && isSuperAdmin) {
      resolvedSekolahNama = 'Pusat (Super Admin)';
    }

    String resolvedEmail = json['email']?.toString() ?? '';
    if (resolvedEmail.isEmpty && json['user'] is Map) {
      resolvedEmail = json['user']['email']?.toString() ?? '';
    }

    return AdminSekolah(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      nama: json['nama_admin']?.toString() ?? json['nama']?.toString() ?? json['name']?.toString() ?? '',
      email: resolvedEmail,
      sekolahId: resolvedSekolahId,
      sekolahNama: resolvedSekolahNama,
      telepon: json['telepon']?.toString() ?? json['phone']?.toString() ?? json['no_hp']?.toString(),
      isActive: json['is_active'] == null
          ? true
          : (json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == 'true'),
      isSuperAdmin: isSuperAdmin,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (userId != null) 'user_id': userId,
    'nama_admin': nama,
    'nama': nama,
    'email': email,
    'sekolah_id': sekolahId,
    'sekolah_nama': sekolahNama,
    if (telepon != null) 'telepon': telepon,
    'is_active': isActive,
    'is_super_admin': isSuperAdmin,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };

  /// Body for POST /api/admin
  Map<String, dynamic> toCreateBody({String? password}) => {
    'nama_admin': nama,
    'sekolah_id': sekolahId,
    if (email.isNotEmpty) 'email': email,
    if (password != null && password.isNotEmpty) 'password': password,
  };

  /// Body for PUT /api/admin/{id}
  Map<String, dynamic> toUpdateBody({String? password}) => {
    'nama_admin': nama,
    'sekolah_id': sekolahId,
    if (password != null && password.isNotEmpty) 'password': password,
  };

  AdminSekolah copyWith({
    String? id,
    String? userId,
    String? nama,
    String? email,
    String? sekolahId,
    String? sekolahNama,
    String? telepon,
    bool? isActive,
    bool? isSuperAdmin,
    String? createdAt,
    String? updatedAt,
  }) {
    return AdminSekolah(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      sekolahId: sekolahId ?? this.sekolahId,
      sekolahNama: sekolahNama ?? this.sekolahNama,
      telepon: telepon ?? this.telepon,
      isActive: isActive ?? this.isActive,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Paginated Admin Response Model according to API GET /api/admin?page=1&limit=20
class PaginatedAdminResponse {
  final bool success;
  final int count;
  final int page;
  final int limit;
  final int totalPages;
  final List<AdminSekolah> data;
  final String? message;

  const PaginatedAdminResponse({
    required this.success,
    required this.count,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.data,
    this.message,
  });

  factory PaginatedAdminResponse.fromJson(
    Map<String, dynamic> json, {
    int defaultPage = 1,
    int defaultLimit = 20,
  }) {
    final rawList = json['data'];
    final List<AdminSekolah> items = [];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map) {
          items.add(AdminSekolah.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return PaginatedAdminResponse(
      success: json['success'] == true,
      count: int.tryParse(json['count']?.toString() ?? '') ?? items.length,
      page: int.tryParse(json['page']?.toString() ?? '') ?? defaultPage,
      limit: int.tryParse(json['limit']?.toString() ?? '') ?? defaultLimit,
      totalPages: int.tryParse(json['totalPages']?.toString() ?? '') ?? 1,
      data: items,
      message: json['message']?.toString(),
    );
  }
}
