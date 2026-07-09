import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';
import 'package:sales_online_app/data/services/login_api.dart';
import 'package:sales_online_app/data/services/password_reset_api.dart';
import 'package:sales_online_app/data/services/register_api.dart';

class ApiAuthRepository implements AuthRepository {
  final LoginApi _loginApi;
  final PasswordResetApi _passwordResetApi;
  final RegisterApi _registerApi;

  ApiAuthRepository({
    LoginApi? loginApi,
    PasswordResetApi? passwordResetApi,
    RegisterApi? registerApi,
  }) : _loginApi = loginApi ?? LoginApi(),
       _passwordResetApi = passwordResetApi ?? PasswordResetApi(),
       _registerApi = registerApi ?? RegisterApi();

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return _loginApi.login(email: email, password: password);
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return _registerApi.register(
      fullName: fullName,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _passwordResetApi.sendPasswordResetEmail(email: email);
  }

  @override
  Future<String> verifyPasswordResetCode({required String code}) {
    return _passwordResetApi.verifyPasswordResetCode(code: code);
  }

  @override
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) {
    return _passwordResetApi.confirmPasswordReset(
      code: code,
      newPassword: newPassword,
    );
  }
}
