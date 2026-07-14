import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/profile_card.dart';

class ModeCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final String currentMode;
  final String buttonText;
  final VoidCallback onPressed;

  const ModeCard({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.currentMode,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      isDark: isDark,
      color: cardColor,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chế độ hiển thị',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                AppSpacing.h8,
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: 'Đang dùng: ',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: currentMode,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.w16,
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 210),
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.xLarge),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  buttonText,
                  maxLines: 1,
                  style: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
