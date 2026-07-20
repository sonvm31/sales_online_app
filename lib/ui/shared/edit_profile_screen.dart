import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/logic/profile/edit_profile_controller.dart';
import 'package:sales_online_app/ui/buyer/order/map_picker_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final AuthController authController;
  final bool isSeller;
  final ShopModel? sellerShop;

  const EditProfileScreen({
    super.key,
    required this.authController,
    required this.isSeller,
    required this.sellerShop,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final EditProfileController _controller;
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _shopNameController;
  late final TextEditingController _shopDescriptionController;
  late final TextEditingController _shopAvatarUrlController;

  String? _selectedShopAddress;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedDeliveryAddress;
  double? _selectedDeliveryLatitude;
  double? _selectedDeliveryLongitude;

  bool get _canEditShop => widget.isSeller && widget.sellerShop != null;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController(
      authController: widget.authController,
      shop: widget.sellerShop,
    );
    _fullNameController = TextEditingController(
      text: widget.authController.session?.fullName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.authController.session?.phone ?? '',
    );
    _shopNameController = TextEditingController(
      text: widget.sellerShop?.name ?? '',
    );
    _shopDescriptionController = TextEditingController(
      text: widget.sellerShop?.description ?? '',
    );
    _shopAvatarUrlController = TextEditingController(
      text: widget.sellerShop?.avatarUrl ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _shopAvatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickShopAddress() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (result == null || !mounted) return;

    final address = result['address']?.toString();
    final latitude = (result['lat'] as num?)?.toDouble();
    final longitude = (result['lng'] as num?)?.toDouble();
    if (address == null || latitude == null || longitude == null) {
      _showMessage('Không thể lấy tọa độ từ địa chỉ đã chọn.');
      return;
    }

    setState(() {
      _selectedShopAddress = address;
      _selectedLatitude = latitude;
      _selectedLongitude = longitude;
    });
  }

  Future<void> _pickDeliveryAddress() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (result == null || !mounted) return;

    final address = result['address']?.toString();
    final latitude = (result['lat'] as num?)?.toDouble();
    final longitude = (result['lng'] as num?)?.toDouble();
    if (address == null || latitude == null || longitude == null) {
      _showMessage('Không thể lấy tọa độ từ địa chỉ đã chọn.');
      return;
    }

    setState(() {
      _selectedDeliveryAddress = address;
      _selectedDeliveryLatitude = latitude;
      _selectedDeliveryLongitude = longitude;
    });
  }

  Future<void> _save() async {
    final saved = await _controller.save(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      shopName: _shopNameController.text,
      shopDescription: _shopDescriptionController.text,
      shopAvatarUrl: _shopAvatarUrlController.text,
      selectedShopAddress: _selectedShopAddress,
      selectedLatitude: _selectedLatitude,
      selectedLongitude: _selectedLongitude,
      selectedDeliveryAddress: _selectedDeliveryAddress,
      selectedDeliveryLatitude: _selectedDeliveryLatitude,
      selectedDeliveryLongitude: _selectedDeliveryLongitude,
    );
    if (!mounted) return;

    if (saved) {
      _showMessage(AppStrings.profileSaveSuccess);
      Navigator.of(context).pop(true);
      return;
    }

    _showMessage(_controller.errorMessage ?? 'Không thể cập nhật hồ sơ.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) => Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text(AppStrings.profileEditTitle),
          backgroundColor: surface,
          foregroundColor: textColor,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionCard(
                title: AppStrings.profilePersonalSection,
                color: surface,
                children: [
                  _ProfileInput(
                    controller: _fullNameController,
                    label: AppStrings.profileFullName,
                  ),
                  AppSpacing.h16,
                  _ProfileInput(
                    controller: _phoneController,
                    label: AppStrings.profilePhone,
                    keyboardType: TextInputType.phone,
                  ),
                  AppSpacing.h16,
                  _DeliveryAddressPicker(
                    address:
                        _selectedDeliveryAddress ??
                        widget.authController.session?.address,
                    onTap: _pickDeliveryAddress,
                  ),
                ],
              ),
              if (_canEditShop) ...[
                AppSpacing.h24,
                _SectionCard(
                  title: AppStrings.profileShopSection,
                  color: surface,
                  children: [
                    _ProfileInput(
                      controller: _shopNameController,
                      label: AppStrings.profileShopName,
                    ),
                    AppSpacing.h16,
                    _ProfileInput(
                      controller: _shopDescriptionController,
                      label: AppStrings.profileShopDescription,
                      maxLines: 3,
                    ),
                    AppSpacing.h16,
                    _ProfileInput(
                      controller: _shopAvatarUrlController,
                      label: AppStrings.profileShopAvatarUrl,
                      keyboardType: TextInputType.url,
                    ),
                    AppSpacing.h16,
                    _ShopAddressPicker(
                      address:
                          _selectedShopAddress ?? widget.sellerShop?.address,
                      onTap: _pickShopAddress,
                    ),
                  ],
                ),
              ],
              AppSpacing.h24,
              ElevatedButton(
                onPressed: _controller.isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  _controller.isSaving ? 'Đang lưu...' : AppStrings.profileSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.headingMedium),
            AppSpacing.h16,
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ProfileInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;

  const _ProfileInput({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _DeliveryAddressPicker extends StatelessWidget {
  final String? address;
  final VoidCallback onTap;

  const _DeliveryAddressPicker({
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.location_on_outlined),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.profileAddress),
          Text(
            address?.isNotEmpty == true
                ? address!
                : 'Chọn địa chỉ giao hàng trên bản đồ',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ShopAddressPicker extends StatelessWidget {
  final String? address;
  final VoidCallback onTap;

  const _ShopAddressPicker({
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.location_on_outlined),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.profileChooseShopAddress),
          if (address != null && address!.isNotEmpty)
            Text(address!, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
