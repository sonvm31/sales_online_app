import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  Timer? _verificationTimer;
  bool _isChecking = false;
  bool _isResending = false;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkVerification(showLoading: false);
    });
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification({bool showLoading = true}) async {
    if (_isChecking || _isPolling) return;

    if (showLoading) {
      setState(() => _isChecking = true);
    } else {
      _isPolling = true;
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser?.emailVerified ?? false) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;

        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Xác thực thành công, vui lòng đăng nhập.'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (showLoading && mounted) {
        setState(() => _isChecking = false);
      }
      _isPolling = false;
    }
  }

  Future<void> _resendEmail() async {
    if (_isResending) return;

    setState(() => _isResending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lại link xác thực.')),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Không thể gửi lại email.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _backToLogin() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
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
                'Đã gửi link xác thực đến ${widget.email}. Vui lòng mở email và bấm link xác thực.',
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
