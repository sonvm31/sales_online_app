import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/shared/auth/password_reset_check_email_screen.dart';
import 'package:sales_online_app/ui/shared/auth/widgets/auth_text_field.dart';

class PasswordResetEmailScreen extends StatefulWidget {
  final AuthController controller;
  final String initialEmail;

  const PasswordResetEmailScreen({
    super.key,
    required this.controller,
    this.initialEmail = '',
  });

  @override
  State<PasswordResetEmailScreen> createState() =>
      _PasswordResetEmailScreenState();
}

class _PasswordResetEmailScreenState extends State<PasswordResetEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final sent = await widget.controller.sendPasswordResetEmail(
      email: _emailController.text,
    );
    if (!mounted) return;

    if (sent) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PasswordResetCheckEmailScreen(
            controller: widget.controller,
            email: _emailController.text.trim(),
          ),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Email chưa đúng định dạng';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? AppColors.textLight : AppColors.textDark;
        final mutedColor = isDark
            ? AppColors.textMutedDark
            : AppColors.textMutedLight;
        final isLoading = widget.controller.isLoading;

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Quay lại',
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                    ),
                    SizedBox(height: 72.h),
                    Container(
                      width: 96.r,
                      height: 96.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 46.r,
                        color: AppColors.primary,
                      ),
                    ),
                    AppSpacing.h32,
                    Text(
                      'Đổi mật khẩu',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display.copyWith(
                        color: textColor,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppSpacing.h8,
                    Text(
                      'Nhập email đã đăng ký để nhận link đổi mật khẩu.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: mutedColor,
                        height: 1.45,
                      ),
                    ),
                    AppSpacing.h32,
                    AuthTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    if (widget.controller.errorMessage != null) ...[
                      AppSpacing.h16,
                      Text(
                        widget.controller.errorMessage!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                    AppSpacing.h32,
                    SizedBox(
                      height: 56.h,
                      child: FilledButton(
                        onPressed: isLoading ? null : _sendResetLink,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.65,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.xLarge,
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : Text(
                                'Gửi link',
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
