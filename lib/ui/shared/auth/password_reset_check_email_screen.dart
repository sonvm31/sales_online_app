import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/shared/auth/password_reset_link_utils.dart';
import 'package:sales_online_app/ui/shared/auth/reset_password_screen.dart';

class PasswordResetCheckEmailScreen extends StatefulWidget {
  final AuthController controller;
  final String email;

  const PasswordResetCheckEmailScreen({
    super.key,
    required this.controller,
    required this.email,
  });

  @override
  State<PasswordResetCheckEmailScreen> createState() =>
      _PasswordResetCheckEmailScreenState();
}

class _PasswordResetCheckEmailScreenState
    extends State<PasswordResetCheckEmailScreen> {
  final AppLinks _appLinks = AppLinks();
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerification({bool showLoading = true}) async {
    if (_isChecking) return;

    if (showLoading) {
      setState(() => _isChecking = true);
    }

    try {
      final latestLink = await _appLinks.getLatestLink();
      final actionUri = extractPasswordResetAction(latestLink);
      final code = actionUri?.queryParameters['oobCode'];

      if (code == null || code.isEmpty) {
        if (mounted && showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chưa nhận được link xác thực đổi mật khẩu.'),
            ),
          );
        }
        return;
      }

      final email = await widget.controller.verifyPasswordResetCode(code: code);
      if (!mounted) return;

      if (email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.controller.errorMessage ??
                  'Link đổi mật khẩu không hợp lệ.',
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResetPasswordScreen(
            controller: widget.controller,
            code: code,
            email: email,
          ),
        ),
      );
    } finally {
      if (showLoading && mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    if (_isResending) return;

    setState(() => _isResending = true);
    try {
      final sent = await widget.controller.sendPasswordResetEmail(
        email: widget.email,
      );
      if (!mounted) return;

      if (sent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi lại link đổi mật khẩu.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _backToLogin() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 96.r,
                height: 96.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 46.r,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.h32,
              Text(
                'Check your email',
                textAlign: TextAlign.center,
                style: AppTextStyles.display.copyWith(
                  color: textColor,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              AppSpacing.h8,
              Text(
                'Đã gửi link đổi mật khẩu đến ${widget.email}. Vui lòng mở email và bấm link xác thực.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: mutedColor,
                  height: 1.45,
                ),
              ),
              AppSpacing.h32,
              FilledButton(
                onPressed: _isChecking ? null : _checkVerification,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.65,
                  ),
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(56.h),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.xLarge),
                ),
                child: _isChecking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : const Text('Tôi đã xác thực'),
              ),
              AppSpacing.h16,
              TextButton(
                onPressed: _isResending ? null : _resendEmail,
                child: Text(_isResending ? 'Đang gửi...' : 'Gửi lại email'),
              ),
              TextButton(
                onPressed: _backToLogin,
                child: const Text('Quay lại đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
