import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/ui/buyer/order/map_picker_screen.dart';

class AddressCard extends StatelessWidget {
  final bool isDark;
  final String selectedAddress;
  final String userName;
  final String userPhone;
  final Function(String address, double lat, double lng) onLocationPicked;

  const AddressCard({
    super.key,
    required this.isDark,
    required this.selectedAddress,
    required this.userName,
    required this.userPhone,
    required this.onLocationPicked,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAddress =
        selectedAddress.isNotEmpty && selectedAddress != "Chưa chọn địa chỉ";
    return GestureDetector(
      onTap: () async {
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
              size: 20,
            ),
            AppSpacing.w8,
            Text(
              "Địa chỉ nhận hàng (Bấm để đổi):",
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            AppSpacing.h8,
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  size: 18,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  userName.isNotEmpty ? userName : "Chưa cập nhật tên",
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
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
