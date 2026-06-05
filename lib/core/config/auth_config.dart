import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/repositories/api_auth_repository.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';
import 'package:sales_online_app/data/repositories/mock_auth_repository.dart';

class AuthConfig {
  AuthConfig._();

  static const bool useMockAuth = true;

  static AuthRepository createRepository() {
    if (useMockAuth) return const MockAuthRepository();
    return ApiAuthRepository(dio: DioClient().dio);
  }
}
