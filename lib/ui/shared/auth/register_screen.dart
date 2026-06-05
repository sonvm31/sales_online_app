import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/ui/shared/auth/widgets/auth_text_field.dart';
import 'package:sales_online_app/ui/shared/auth/widgets/social_login_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sẵn sàng tích hợp Firebase Auth')),
    );
  }

  void _handleGoogleRegister() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sẵn sàng tích hợp Google Sign-In')),
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
    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final primaryTextColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedTextColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.h),
                  _BackButton(isDark: isDark),
                  SizedBox(height: 24.h),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Tạo tài khoản',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display.copyWith(
                            color: primaryTextColor,
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AppSpacing.h8,
                        Text(
                          'Tham gia ngay để nhận hàng ngàn ưu đãi',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: mutedTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 46.h),
                  AuthTextField(
                    controller: _fullNameController,
                    hintText: 'Họ và tên',
                    icon: Icons.person_outline_rounded,
                    validator: _validateFullName,
                  ),
                  SizedBox(height: 18.h),
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 18.h),
                  AuthTextField(
                    controller: _passwordController,
                    hintText: 'Mật khẩu',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: mutedTextColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),
                  _PrimaryRegisterButton(
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleRegister,
                  ),
                  SizedBox(height: 22.h),
                  _DividerLabel(isDark: isDark),
                  SizedBox(height: 22.h),
                  SocialLoginButton(
                    label: 'Đăng ký với Google',
                    onPressed: _handleGoogleRegister,
                  ),
                  SizedBox(height: 26.h),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Đã có tài khoản? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: mutedTextColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
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
                  SizedBox(height: 34.h),
                ],
              ),
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
    return Container(
      width: double.infinity,
      height: 66.h,
      decoration: BoxDecoration(
        borderRadius: AppRadius.xLarge,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.72),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xLarge),
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