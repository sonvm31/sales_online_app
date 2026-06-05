import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  final AuthController controller;

  const LoginScreen({super.key, required this.controller});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await widget.controller.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : const Color(0xFFFAFBFC);
    final borderColor = isDark ? AppColors.borderDark : const Color(0xFFE2E5EA);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BrandLogo(isDark: isDark),
                    SizedBox(height: 34.h),
                    Text(
                      'Sales Online',
                      style: AppTextStyles.display.copyWith(
                        color: textColor,
                        fontSize: 38.sp,
                        letterSpacing: -1.2,
                      ),
                    ),
                    AppSpacing.h8,
                    Text(
                      'Đăng nhập để trải nghiệm mua sắm tuyệt vời',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: mutedColor,
                        fontSize: 17.sp,
                      ),
                    ),
                    SizedBox(height: 52.h),
                    _AuthTextField(
                      fieldKey: const Key('email_field'),
                      controller: _emailController,
                      icon: Icons.mail_outline_rounded,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      mutedColor: mutedColor,
                      onFieldSubmitted: (_) =>
                          _passwordFocusNode.requestFocus(),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Vui lòng nhập email';
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return 'Email không đúng định dạng';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.h16,
                    _AuthTextField(
                      fieldKey: const Key('password_field'),
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      icon: Icons.lock_outline_rounded,
                      hintText: 'Mật khẩu',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      mutedColor: mutedColor,
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
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    if (widget.controller.errorMessage != null) ...[
                      AppSpacing.h16,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.controller.errorMessage!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.red.shade600,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 60.h,
                      child: FilledButton(
                        key: const Key('login_button'),
                        onPressed: widget.controller.isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.65,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.xLarge,
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: widget.controller.isLoading
                            ? SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Đăng nhập',
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                ),
                              ),
                      ),
                    ),
                    AppSpacing.h24,
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản? ',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: mutedColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Màn hình đăng ký sẽ được bổ sung sau.',
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Đăng ký',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  final bool isDark;

  const _BrandLogo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112.w,
      height: 112.w,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.22),
            blurRadius: 28.r,
            offset: Offset(0, 14.h),
          ),
        ],
      ),
      child: Icon(Icons.storefront_outlined, size: 54.r, color: Colors.white),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final Key? fieldKey;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Color surfaceColor;
  final Color borderColor;
  final Color mutedColor;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;

  const _AuthTextField({
    this.fieldKey,
    required this.controller,
    required this.icon,
    required this.hintText,
    required this.surfaceColor,
    required this.borderColor,
    required this.mutedColor,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: obscureText
          ? const [AutofillHints.password]
          : const [AutofillHints.email],
      style: AppTextStyles.bodyLarge,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: mutedColor.withValues(alpha: 0.75),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Icon(icon, color: mutedColor.withValues(alpha: 0.75)),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 56.w),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: surfaceColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 21.h,
        ),
        border: _border(borderColor),
        enabledBorder: _border(borderColor),
        focusedBorder: _border(AppColors.primary, width: 1.5),
        errorBorder: _border(Colors.red.shade400),
        focusedErrorBorder: _border(Colors.red.shade400, width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadius.xLarge,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
