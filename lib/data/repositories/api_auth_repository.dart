import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';
import 'package:sales_online_app/data/services/login_api.dart';
import 'package:sales_online_app/data/services/register_api.dart';

class ApiAuthRepository implements AuthRepository {
  final LoginApi _loginApi;
  final RegisterApi _registerApi;

  ApiAuthRepository({LoginApi? loginApi, RegisterApi? registerApi})
    : _loginApi = loginApi ?? LoginApi(),
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
}
