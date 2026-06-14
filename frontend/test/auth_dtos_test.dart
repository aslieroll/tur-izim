import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/features/auth/domain/auth_dtos.dart';
import 'package:tur_izim/shared/models/user_role.dart';

void main() {
  group('AuthResponse.fromJson', () {
    test('maps creator with profile id', () {
      final r = AuthResponse.fromJson({
        'token': 'jwt-here',
        'userId': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'role': 'CREATOR',
        'email': 'a@b.com',
        'fullName': 'Ali Veli',
        'creatorProfileId': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        'agencyId': null,
      });
      expect(r.token, 'jwt-here');
      expect(r.role, UserRole.creator);
      expect(r.creatorProfileId, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb');
      expect(r.agencyId, isNull);
    });

    test('maps agency role', () {
      final r = AuthResponse.fromJson({
        'token': 't',
        'userId': 'u1',
        'role': 'AGENCY',
        'email': 'x@y.com',
        'fullName': 'ACME',
        'creatorProfileId': null,
        'agencyId': 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      });
      expect(r.role, UserRole.agency);
      expect(r.agencyId, 'cccccccc-cccc-cccc-cccc-cccccccccccc');
    });
  });

  group('CurrentUserResponse.fromJson', () {
    test('maps ADMIN', () {
      final m = CurrentUserResponse.fromJson({
        'userId': 'admin-u',
        'role': 'ADMIN',
        'email': 'admin@test.com',
        'fullName': 'Admin',
        'creatorProfileId': null,
        'agencyId': null,
      });
      expect(m.role, UserRole.admin);
    });
  });

  group('userRoleFromApi', () {
    test('accepts lowercase', () {
      expect(userRoleFromApi('creator'), UserRole.creator);
    });
  });
}
