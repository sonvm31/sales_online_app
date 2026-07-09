import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/shared/auth/password_reset_link_utils.dart';
import 'package:sales_online_app/ui/shared/auth/reset_password_screen.dart';

class PasswordResetLinkHandler extends StatefulWidget {
  final AuthController controller;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const PasswordResetLinkHandler({
    super.key,
    required this.controller,
    required this.navigatorKey,
    required this.child,
  });

  @override
  State<PasswordResetLinkHandler> createState() =>
      _PasswordResetLinkHandlerState();
}

class _PasswordResetLinkHandlerState extends State<PasswordResetLinkHandler> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  String? _lastHandledCode;
  bool _isHandlingLink = false;

  @override
  void initState() {
    super.initState();
    _listenForPasswordResetLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _listenForPasswordResetLinks() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleUri(initialLink);
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  Future<void> _handleUri(Uri uri) async {
    final actionUri = extractPasswordResetAction(uri);
    final code = actionUri?.queryParameters['oobCode'];

    if (code == null ||
        code.isEmpty ||
        code == _lastHandledCode ||
        _isHandlingLink) {
      return;
    }

    _isHandlingLink = true;
    _lastHandledCode = code;

    final email = await widget.controller.verifyPasswordResetCode(code: code);
    if (!mounted) return;

    if (email == null) {
      _showMessage(
        widget.controller.errorMessage ?? 'Link đổi mật khẩu không hợp lệ.',
        isError: true,
      );
      _isHandlingLink = false;
      _lastHandledCode = null;
      return;
    }

    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) {
      _isHandlingLink = false;
      _lastHandledCode = null;
      return;
    }

    await navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => ResetPasswordScreen(
          controller: widget.controller,
          code: code,
          email: email,
        ),
      ),
      (route) => route.isFirst,
    );

    _isHandlingLink = false;
    _lastHandledCode = null;
  }

  void _showMessage(String message, {bool isError = false}) {
    final context = widget.navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
