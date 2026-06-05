import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';
import 'package:sales_online_app/data/services/auth_session_service.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/shared/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows validation messages for empty credentials', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester);
    final controller = _buildController();

    await tester.pumpWidget(_TestApp(controller: controller));
    final loginButton = find.byKey(const Key('login_button'));
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
  });

  testWidgets('submits valid credentials through AuthRepository', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester);
    final repository = _FakeAuthRepository();
    final controller = _buildController(repository: repository);

    await tester.pumpWidget(_TestApp(controller: controller));
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'buyer@example.com',
    );
    await tester.enterText(find.byKey(const Key('password_field')), '123456');
    final loginButton = find.byKey(const Key('login_button'));
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(repository.lastEmail, 'buyer@example.com');
    expect(repository.lastPassword, '123456');
    expect(controller.status, AuthStatus.authenticated);
    expect(controller.session?.accessToken, 'test-token');
  });
}

void _setTestViewport(WidgetTester tester) {
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
}

AuthController _buildController({AuthRepository? repository}) {
  return AuthController(
    repository: repository ?? _FakeAuthRepository(),
    sessionService: AuthSessionService(),
  );
}

class _TestApp extends StatelessWidget {
  final AuthController controller;

  const _TestApp({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return MaterialApp(home: LoginScreen(controller: controller));
      },
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  String? lastEmail;
  String? lastPassword;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    return AuthSession(accessToken: 'test-token', email: email);
  }
}
