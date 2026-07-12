import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/shared/auth/widgets/auth_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final AuthController controller;
  final String code;
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.controller,
    required this.code,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final changed = await widget.controller.confirmPasswordReset(
      code: widget.code,
      newPassword: _passwordController.text,
    );
    if (!mounted) return;

    if (changed) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đổi mật khẩu thành công. Vui lòng đăng nhập.'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu mới';
    if (value.length < 6) return 'Mật khẩu cần ít nhất 6 ký tự';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu mới';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu nhập lại không khớp';
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
                    SizedBox(height: 96.h),
                    Container(
                      width: 96.r,
                      height: 96.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_open_rounded,
                        size: 46.r,
                        color: AppColors.primary,
                      ),
                    ),
                    AppSpacing.h32,
                    Text(
                      'Mật khẩu mới',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display.copyWith(
                        color: textColor,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppSpacing.h8,
                    Text(
                      'Đặt mật khẩu mới cho ${widget.email}.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: mutedColor,
                        height: 1.45,
                      ),
                    ),
                    AppSpacing.h32,
                    AuthTextField(
                      controller: _passwordController,
                      hintText: 'Mật khẩu mới',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      validator: _validatePassword,
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Hiện mật khẩu'
                            : 'Ẩn mật khẩu',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: mutedColor,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md + 2.h),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Nhập lại mật khẩu mới',
                      icon: Icons.lock_reset_rounded,
                      obscureText: _obscureConfirmPassword,
                      validator: _validateConfirmPassword,
                      suffixIcon: IconButton(
                        tooltip: _obscureConfirmPassword
                            ? 'Hiện mật khẩu'
                            : 'Ẩn mật khẩu',
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: mutedColor,
                        ),
                      ),
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
                        onPressed: isLoading ? null : _submit,
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
                                'Cập nhật mật khẩu',
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
