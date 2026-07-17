import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class ShopPreviewButton extends StatelessWidget {
  final VoidCallback onTap;

  const ShopPreviewButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const previewBackground = Color(0xFF172132);
    const previewMuted = Color(0xFFB7C0CF);

    return Material(
      color: previewBackground,
      borderRadius: AppRadius.xLarge,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xLarge,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.xLarge,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.13),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trang hiển thị Shop',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    AppSpacing.h8,
                    Text(
                      'Xem giao diện khách hàng nhìn thấy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: previewMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.w16,
              const Icon(
                Icons.arrow_forward_rounded,
                color: previewMuted,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
