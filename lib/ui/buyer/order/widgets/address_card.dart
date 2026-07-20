import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/buyer/order/map_picker_screen.dart';
import 'package:sales_online_app/ui/shared/profile_screen.dart';

class AddressCard extends StatelessWidget {
  final bool isDark;
  final String selectedAddress;
  final String userName;
  final String userPhone;
  final AuthController authController;
  final Function(String address, double lat, double lng) onLocationPicked;

  const AddressCard({
    super.key,
    required this.isDark,
    required this.selectedAddress,
    required this.userName,
    required this.userPhone,
    required this.onLocationPicked,
    required this.authController
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAddress =
        selectedAddress.isNotEmpty && selectedAddress != "Chưa chọn địa chỉ";
    final bool hasPhone = userPhone.isNotEmpty && userPhone.trim().toLowerCase() != "chưa có sđt";
    return GestureDetector(
      onTap: () async {
        if (!hasPhone) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vui lòng cập nhật số điện thoại trước khi đặt hàng!"),
              backgroundColor: Colors.orange,
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(controller: authController),
            ),
          );
          return;
        }
        final Map<String, dynamic>? result =
            await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(builder: (context) => const MapPickerScreen()),
            );
        if (result != null) {
          onLocationPicked(result['address'], result['lat'], result['lng']);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.large,
          border: Border.all(
            color: hasAddress
                ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                : (isDark ? Colors.orangeAccent : Colors.orange),
            width: hasAddress ? 1.0 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_rounded,
              color: hasAddress ? AppColors.primary : Colors.orange,
              size: 20.sp,
            ),
            AppSpacing.w8,
            Text(
              "Địa chỉ nhận hàng (Bấm để đổi):",
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            AppSpacing.h8,
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                            size: 18.sp,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              userName.isNotEmpty ? userName : "Chưa cập nhật tên",
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            "  |  ",
                            style: TextStyle(
                              color: isDark ? Colors.white30 : Colors.black26,
                            ),
                          ),
                    Text(
                      userPhone.isNotEmpty ? userPhone : "Chưa có SĐT",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            AppSpacing.h8,
            Text(
              hasAddress
                  ? selectedAddress
                  : "Bạn chưa chọn địa chỉ giao hàng. Vui lòng bấm vào đây để chọn vị trí trên bản đồ!",
              style: AppTextStyles.bodyMedium.copyWith(
                color: hasAddress
                    ? (isDark ? AppColors.textLight : AppColors.textDark)
                    : (isDark ? Colors.orangeAccent : Colors.orange.shade800),
                fontWeight: hasAddress ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
