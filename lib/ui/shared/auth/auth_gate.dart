import 'package:flutter/material.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/shared/auth/login_screen.dart';
import 'package:sales_online_app/ui/shared/main_wrapper_screen.dart';

class AuthGate extends StatelessWidget {
  final AuthController controller;

  const AuthGate({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        switch (controller.status) {
          case AuthStatus.checking:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.authenticated:
            // Recreate tab/profile state whenever another account is restored
            // or signs in, so a previous seller mode cannot leak into buyer UI.
            return MainWrapperScreen(
              key: ValueKey('main-wrapper-${controller.session?.userId}'),
              controller: controller,
            );
          case AuthStatus.unauthenticated:
          case AuthStatus.authenticating:
            return LoginScreen(controller: controller);
        }
      },
    );
  }
}
