import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/config/auth_config.dart';
import 'package:sales_online_app/core/theme/app_theme.dart';
import 'package:sales_online_app/core/theme/theme_provider.dart';
import 'package:sales_online_app/data/services/auth_session_service.dart';
import 'package:sales_online_app/firebase_options.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/shared/auth/auth_gate.dart';

late final ThemeProvider themeProvider;
late final AuthController authController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  themeProvider = ThemeProvider();
  authController = AuthController(
    repository: AuthConfig.createRepository(),
    sessionService: AuthSessionService(),
  );
  await authController.restoreSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: themeProvider,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Sales Online System',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.dartTheme,
              themeMode: themeProvider.currTheme,
              home: AuthGate(controller: authController),
            );
          },
        );
      },
    );
  }
}
