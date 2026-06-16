import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/auth/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson parses full payload', () {
      final u = UserModel.fromJson({
        'id': 'u-1',
        'name': 'Admin Apotek',
        'username': 'admin',
        'email': 'admin@apotek.test',
        'role': 'ADMIN',
      });
      expect(u.id, 'u-1');
      expect(u.name, 'Admin Apotek');
      expect(u.username, 'admin');
      expect(u.email, 'admin@apotek.test');
      expect(u.role, 'ADMIN');
    });

    test('fromJson tolerates missing optional fields', () {
      final u = UserModel.fromJson({
        'id': 'u-1',
        'name': 'Admin',
        'username': 'admin',
      });
      expect(u.email, isNull);
      expect(u.role, 'ADMIN');
    });

    test('toJson round-trips', () {
      final u = UserModel(
        id: 'u-1',
        name: 'Admin',
        username: 'admin',
        email: 'admin@apotek.test',
        role: 'ADMIN',
      );
      final json = u.toJson();
      final u2 = UserModel.fromJson(json);
      expect(u2.id, u.id);
      expect(u2.name, u.name);
      expect(u2.username, u.username);
      expect(u2.email, u.email);
      expect(u2.role, u.role);
    });
  });
}
