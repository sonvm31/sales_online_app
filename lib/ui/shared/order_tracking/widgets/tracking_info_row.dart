import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class TrackingInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const TrackingInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
