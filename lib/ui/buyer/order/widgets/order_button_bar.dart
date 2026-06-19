import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/buyer/order_controller.dart';
import 'package:sales_online_app/ui/buyer/order/order_success_screen.dart';
import 'package:sales_online_app/ui/buyer/order/vnpay_payment_screen.dart';

class OrderButtonBar extends StatelessWidget {
  final bool isDark;
  final OrderController controller;

  const OrderButtonBar({
    super.key,
    required this.isDark,
    required this.controller,
  });

  Future<void> _handleOrderProcessing(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final String? orderResult = await controller.processPlaceOrder();
    debugPrint("chay duoc toi day roi ne");

    if (orderResult == null) {
      if (controller.errMessage != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(controller.errMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (controller.selectedPaymentMethod == "VNPAY" && orderResult.isNotEmpty) {
      final bool? isPaidSuccess = await navigator.push<bool>(
        MaterialPageRoute(
          builder: (context) => VNPayPaymentScreen(paymentUrl: orderResult),
        ),
      );

      if (isPaidSuccess == true) {
        await navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) =>
                OrderSuccessScreen(summary: controller.buildOrderSummary()),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text("Thanh toán thất bại hoặc đơn đã bị hủy."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      await navigator.pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) =>
              OrderSuccessScreen(summary: controller.buildOrderSummary()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAddress =
        controller.selectedAddress.isNotEmpty &&
        controller.selectedAddress != "Chưa chọn địa chỉ";
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.0.h,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return ElevatedButton(
              onPressed: hasAddress
                  ? () => _handleOrderProcessing(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
                elevation: 0,
              ),
              child: Text(
                "Tiến hành Đặt hàng",
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
