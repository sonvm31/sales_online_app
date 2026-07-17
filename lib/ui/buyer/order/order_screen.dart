import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';
import 'package:sales_online_app/logic/buyer/order_controller.dart';
import 'package:sales_online_app/logic/cart/cart_controller.dart';
import 'package:sales_online_app/main.dart';
import 'package:sales_online_app/ui/buyer/order/widgets/address_card.dart';
import 'package:sales_online_app/ui/buyer/order/widgets/order_button_bar.dart';
import 'package:sales_online_app/ui/buyer/order/widgets/order_summary_card.dart';
import 'package:sales_online_app/ui/buyer/order/widgets/payment_method_card.dart';

class OrderScreen extends StatefulWidget {
  final List<CartItemModel> selectedCartItems;
  final CartController cartController;

  const OrderScreen({super.key, required this.selectedCartItems, required this.cartController});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late OrderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OrderController(
      orderItems: widget.selectedCartItems,
      authController: authController,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = FirebaseAuth.instance.currentUser;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(
              "Thanh toán",
              style: AppTextStyles.headingLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textDark,
              ),
            ),
            backgroundColor: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          body: _controller.isLoading
              ? const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
              : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      AddressCard(
                        isDark: isDark,
                        userName: user?.displayName ?? "Chưa cập nhật tên",
                        userPhone: user?.phoneNumber ?? "Chưa cập nhật SĐT",
                        selectedAddress: _controller.selectedAddress,
                        onLocationPicked: (address, lat, lng) =>
                            _controller.updateLocationInfo(
                              address: address,
                              lat: lat,
                              lng: lng,
                            ),
                      ),
                      AppSpacing.h16,
                      OrderSummaryCard(
                        isDark: isDark,
                        orderItems: _controller.orderItems,
                        totalProductPrice: _controller.totalProductPrice,
                        shippingFee: _controller.shippingFee,
                        isCalculatingShipping: _controller.isCalculatingShipping,
                      ),
                      AppSpacing.h16,
                      PaymentMethodCard(
                        isDark: isDark,
                        selectedPaymentMethod:
                        _controller.selectedPaymentMethod,
                        onMethodChanged: (method) =>
                            _controller.setPaymentMethod(method),
                      ),
                    ],
                  ),
                ),
              ),
              OrderButtonBar(isDark: isDark, controller: _controller, cartController: widget.cartController,),
            ],
          ),
        );
      },
    );
  }
}
