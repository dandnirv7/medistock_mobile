import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/auth/models/user_model.dart';

void main() {
  group('LoginResponse', () {
    test('fromJson unwraps envelope and reads accessToken + user', () {
      // Mirrors actual backend payload shape
      // (envelope -> data -> { accessToken, user }).
      final res = LoginResponse.fromJson({
        'success': true,
        'message': 'Success',
        'data': {
          'accessToken': 'eyJhbGciOi...',
          'user': {
            'id': '11111111-1111-1111-1111-111111111111',
            'name': 'Admin Apotek',
            'username': 'admin',
            'email': 'admin@medistock.local',
            'role': 'ADMIN',
          },
        },
      });
      expect(res.token, 'eyJhbGciOi...');
      expect(res.user.username, 'admin');
      expect(res.user.role, 'ADMIN');
      expect(res.user.email, 'admin@medistock.local');
    });

    test('fromJson tolerates flat shape (no envelope, data inlined)', () {
      final res = LoginResponse.fromJson({
        'accessToken': 'flat.token.value',
        'user': {
          'id': 'u-1',
          'name': 'Admin',
          'username': 'admin',
          'role': 'ADMIN',
        },
      });
      expect(res.token, 'flat.token.value');
      expect(res.user.username, 'admin');
    });

    test('fromJson falls back to token field if accessToken missing', () {
      final res = LoginResponse.fromJson({
        'data': {
          'token': 'legacy.token',
          'user': {'id': 'u-1', 'name': 'A', 'username': 'a'},
        },
      });
      expect(res.token, 'legacy.token');
    });
  });
}
