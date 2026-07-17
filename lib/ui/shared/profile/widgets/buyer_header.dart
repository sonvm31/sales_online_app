import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class BuyerHeader extends StatelessWidget {
  final String displayName;

  const BuyerHeader({super.key, required this.displayName});

  @override
  Widget build(BuildContext context) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.xl),
          bottomRight: Radius.circular(AppSpacing.xl),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.surfaceLight,
            child: Text(
              initial,
              style: AppTextStyles.display.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                AppSpacing.h8,
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF65E46F),
                      size: 17,
                    ),
                    AppSpacing.w4,
                    Text(
                      'Đã xác thực',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
