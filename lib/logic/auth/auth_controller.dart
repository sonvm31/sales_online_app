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

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
      );
      _session = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Không thể đăng ký. Vui lòng thử lại sau.';
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.sendPasswordResetEmail(email: email.trim());
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Không thể gửi link đổi mật khẩu. Vui lòng thử lại sau.';
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<String?> verifyPasswordResetCode({required String code}) async {
    try {
      return _repository.verifyPasswordResetCode(code: code);
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Link đổi mật khẩu không hợp lệ.';
    }
    notifyListeners();
    return null;
  }

  Future<bool> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Không thể cập nhật mật khẩu. Vui lòng thử lại sau.';
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<void> updateSessionProfile({String? fullName, String? phone}) async {
    final currentSession = _session;
    if (currentSession == null) return;

    _session = currentSession.copyWith(fullName: fullName, phone: phone);
    await _sessionService.save(_session!);
    notifyListeners();
  }

  Future<void> logout() async {
    await _sessionService.clear();
    _session = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
