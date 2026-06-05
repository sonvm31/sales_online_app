import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/shared/auth/widgets/auth_text_field.dart';
import 'package:sales_online_app/ui/shared/auth/widgets/social_login_button.dart';

class RegisterScreen extends StatefulWidget {
  final AuthController controller;

  const RegisterScreen({super.key, required this.controller});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await widget.controller.register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _handleGoogleRegister() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In sẽ được tích hợp sau khi Firebase sẵn sàng.'),
      ),
    );
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (email.isEmpty) {
      return 'Vui lòng nhập email';
    }

    if (!emailPattern.hasMatch(email)) {
      return 'Email chưa đúng định dạng';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 6) {
      return 'Mật khẩu cần ít nhất 6 ký tự';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
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
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.xl + 8.h),
                _BackButton(isDark: isDark),
                SizedBox(height: AppSpacing.lg),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Tạo tài khoản',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display.copyWith(
                          color: textColor,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      AppSpacing.h8,
                      Text(
                        'Tham gia ngay để nhận hàng ngàn ưu đãi',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl + 14.h),
                AuthTextField(
                  controller: _fullNameController,
                  hintText: 'Họ và tên',
                  icon: Icons.person_outline_rounded,
                  validator: _validateFullName,
                ),
                SizedBox(height: AppSpacing.md + 2.h),
                AuthTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: AppSpacing.md + 2.h),
                AuthTextField(
                  controller: _passwordController,
                  hintText: 'Mật khẩu',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
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
                if (widget.controller.errorMessage != null) ...[
                  AppSpacing.h16,
                  Text(
                    widget.controller.errorMessage!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.xl + 4.h),
                _PrimaryRegisterButton(
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleRegister,
                ),
                SizedBox(height: AppSpacing.lg - 2.h),
                _DividerLabel(isDark: isDark),
                SizedBox(height: AppSpacing.lg - 2.h),
                SocialLoginButton(
                  label: 'Đăng ký với Google',
                  onPressed: _handleGoogleRegister,
                ),
                SizedBox(height: AppSpacing.lg + 2.h),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: mutedColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Đăng nhập',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final bool isDark;

  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      borderRadius: AppRadius.circular,
      child: Container(
        width: 48.r,
        height: 48.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? AppColors.textLight : AppColors.textDark,
          size: 20.r,
        ),
      ),
    );
  }
}

class _PrimaryRegisterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryRegisterButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 66.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.65),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xLarge),
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                'Đăng ký ngay',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  final bool isDark;

  const _DividerLabel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final dividerColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Hoặc',
            style: AppTextStyles.bodyMedium.copyWith(color: textColor),
          ),
        ),
        Expanded(child: Divider(color: dividerColor)),
      ],
    );
  }
}