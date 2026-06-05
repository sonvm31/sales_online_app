import 'package:flutter/foundation.dart';
import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';
import 'package:sales_online_app/data/services/auth_session_service.dart';

enum AuthStatus { checking, unauthenticated, authenticating, authenticated }

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  final AuthSessionService _sessionService;

  AuthStatus _status = AuthStatus.checking;
  AuthSession? _session;
  String? _errorMessage;

  AuthController({
    required AuthRepository repository,
    required AuthSessionService sessionService,
  }) : _repository = repository,
       _sessionService = sessionService;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.authenticating;

  Future<void> restoreSession() async {
    try {
      _session = await _sessionService.read();
    } catch (_) {
      _session = null;
    }
    _status = _session == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _repository.login(
        email: email.trim(),
        password: password,
      );
      await _sessionService.save(session);
      _session = session;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Không thể đăng nhập. Vui lòng thử lại sau.';
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _sessionService.clear();
    _session = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
