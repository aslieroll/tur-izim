import '../../../shared/models/user_role.dart';

UserRole userRoleFromApi(String raw) {
  switch (raw.trim().toUpperCase()) {
    case 'CREATOR':
      return UserRole.creator;
    case 'AGENCY':
      return UserRole.agency;
    case 'ADMIN':
      return UserRole.admin;
    default:
      throw FormatException('Bilinmeyen rol: $raw');
  }
}

String? _uuidString(Object? v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

/// Maps to backend [com.turizim.auth.dto.AuthResponse].
final class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.userId,
    required this.role,
    required this.email,
    required this.fullName,
    this.creatorProfileId,
    this.agencyId,
  });

  final String token;
  final String userId;
  final UserRole role;
  final String email;
  final String fullName;
  final String? creatorProfileId;
  final String? agencyId;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final roleRaw = json['role']?.toString();
    if (roleRaw == null) {
      throw const FormatException('role eksik');
    }
    return AuthResponse(
      token: json['token']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      role: userRoleFromApi(roleRaw),
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      creatorProfileId: _uuidString(json['creatorProfileId']),
      agencyId: _uuidString(json['agencyId']),
    );
  }
}

/// Maps to backend [com.turizim.auth.dto.CurrentUserResponse].
final class CurrentUserResponse {
  const CurrentUserResponse({
    required this.userId,
    required this.role,
    required this.email,
    required this.fullName,
    this.creatorProfileId,
    this.agencyId,
  });

  final String userId;
  final UserRole role;
  final String email;
  final String fullName;
  final String? creatorProfileId;
  final String? agencyId;

  factory CurrentUserResponse.fromJson(Map<String, dynamic> json) {
    final roleRaw = json['role']?.toString();
    if (roleRaw == null) {
      throw const FormatException('role eksik');
    }
    return CurrentUserResponse(
      userId: json['userId']?.toString() ?? '',
      role: userRoleFromApi(roleRaw),
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      creatorProfileId: _uuidString(json['creatorProfileId']),
      agencyId: _uuidString(json['agencyId']),
    );
  }
}

final class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

/// Backend `RegisterCreatorRequest` — optional booleans omitted → JSON null; service treats as false.
final class RegisterCreatorRequest {
  const RegisterCreatorRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.universityName,
    required this.city,
    required this.passportType,
    required this.hasValidPassport,
    this.hasSchengenVisa,
    this.hasUsVisa,
    this.hasUkVisa,
    this.hasOtherValidVisa,
  });

  final String fullName;
  final String email;
  final String password;
  final String universityName;
  final String city;

  /// Upper snake-case e.g. `TURKISH_ORDINARY`
  final String passportType;
  final bool hasValidPassport;
  final bool? hasSchengenVisa;
  final bool? hasUsVisa;
  final bool? hasUkVisa;
  final bool? hasOtherValidVisa;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
        'universityName': universityName,
        'city': city,
        'passportType': passportType,
        'hasValidPassport': hasValidPassport,
        'hasSchengenVisa': hasSchengenVisa,
        'hasUsVisa': hasUsVisa,
        'hasUkVisa': hasUkVisa,
        'hasOtherValidVisa': hasOtherValidVisa,
      };
}

/// Backend `RegisterAgencyRequest` uses `contactEmail` (not `email`).
final class RegisterAgencyRequest {
  const RegisterAgencyRequest({
    required this.name,
    required this.contactEmail,
    required this.password,
    required this.phone,
    required this.city,
  });

  final String name;
  final String contactEmail;
  final String password;
  final String phone;
  final String city;

  Map<String, dynamic> toJson() => {
        'name': name,
        'contactEmail': contactEmail,
        'password': password,
        'phone': phone,
        'city': city,
      };
}

/// PassportType string values aligned with backend enum names.
abstract final class PassportTypeApi {
  PassportTypeApi._();

  static const none = 'NONE';
  static const other = 'OTHER';
  static const turkishOrdinary = 'TURKISH_ORDINARY';
  static const turkishSpecial = 'TURKISH_SPECIAL';
  static const turkishService = 'TURKISH_SERVICE';
  static const turkishDiplomatic = 'TURKISH_DIPLOMATIC';

  static const List<(String value, String label)> pickerEntries = [
    (turkishOrdinary, 'Türkiye C. (Umumi)'),
    (turkishSpecial, 'Türkiye C. (Hususi)'),
    (turkishService, 'Türkiye C. (Hizmet)'),
    (turkishDiplomatic, 'Türkiye C. (Diplomatik)'),
    (other, 'Diğer'),
    (none, 'Yok / beyan etmiyorum'),
  ];
}
