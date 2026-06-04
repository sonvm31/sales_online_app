  import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/main.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: AppSpacing.xxl + 12,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.lg
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xLarge.topLeft.x * 2),
          bottomRight: Radius.circular(AppRadius.xLarge.topRight.x * 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: AppRadius.circular,
                ),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.search, color: Colors.white, size: 24),
                    AppSpacing.w8,
                    Text(
                      "Tìm kiếm sản phẩm ...",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.whitePlaceholder),
                    ),
                  ],
                ),
              ),
          ),
          AppSpacing.w16,
          InkWell(
            onTap: () => {},
            borderRadius: AppRadius.circular,
            child: Container(
              height: 48,
              width: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(CupertinoIcons.bell, color: Colors.white, size: 24),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}