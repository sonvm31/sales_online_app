import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (email.toLowerCase() == 'error@example.com') {
      throw const AuthException('Email hoặc mật khẩu không chính xác.');
    }

    return AuthSession(
      accessToken: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
    );
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (email.toLowerCase() == 'exists@example.com') {
      throw const AuthException('Email này đã được sử dụng.');
    }

    return AuthSession(
      accessToken: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
    );
  }
}
