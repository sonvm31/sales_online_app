import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/ui/buyer/order/map_picker_screen.dart';

class ShopRegistrationDialog extends StatefulWidget {
  final Future<void> Function({
    required String name,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required String avatarUrl,
  })
  onSubmit;

  const ShopRegistrationDialog({super.key, required this.onSubmit});

  @override
  State<ShopRegistrationDialog> createState() => _ShopRegistrationDialogState();
}

class _ShopRegistrationDialogState extends State<ShopRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  String? _selectedAddress;
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || _formKey.currentState?.validate() != true) return;
    if (!_hasSelectedAddress) {
      setState(() {
        _errorMessage = 'Vui lòng chọn địa chỉ shop trên bản đồ.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onSubmit(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _selectedAddress!,
        latitude: _selectedLatitude!,
        longitude: _selectedLongitude!,
        avatarUrl: _avatarUrlController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool get _hasSelectedAddress =>
      _selectedAddress != null &&
      _selectedAddress!.trim().isNotEmpty &&
      _selectedLatitude != null &&
      _selectedLongitude != null;

  Future<void> _pickShopAddress() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );

    if (result == null) return;

    final address = result['address']?.toString();
    final lat = (result['lat'] as num?)?.toDouble();
    final lng = (result['lng'] as num?)?.toDouble();

    if (address == null || lat == null || lng == null) {
      setState(() {
        _errorMessage = 'Không thể lấy tọa độ từ địa chỉ đã chọn.';
      });
      return;
    }

    setState(() {
      _selectedAddress = address;
      _selectedLatitude = lat;
      _selectedLongitude = lng;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      title: Text(
        'Bắt đầu bán hàng',
        style: AppTextStyles.headingMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Điền thông tin shop. Địa chỉ shop sẽ được chọn trên bản đồ để tự lấy tọa độ.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: mutedColor,
                  height: 1.35,
                ),
              ),
              AppSpacing.h16,
              _ShopTextField(
                controller: _nameController,
                label: 'Tên shop',
                hintText: 'Ví dụ: Phụ Kiện AZ',
                validator: _requiredValidator,
              ),
              AppSpacing.h16,
              _ShopTextField(
                controller: _descriptionController,
                label: 'Mô tả shop',
                hintText: 'Mô tả ngắn về shop của bạn',
                maxLines: 3,
                validator: _requiredValidator,
              ),
              AppSpacing.h16,
              _AddressPickerField(
                address: _selectedAddress,
                onTap: _isSubmitting ? null : _pickShopAddress,
              ),
              AppSpacing.h16,
              _ShopTextField(
                controller: _avatarUrlController,
                label: 'Avatar shop URL',
                hintText: 'https://...',
                keyboardType: TextInputType.url,
                validator: _urlValidator,
              ),
              if (_errorMessage != null) ...[
                AppSpacing.h16,
                Text(
                  _errorMessage!,
                  style: AppTextStyles.caption.copyWith(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Gửi đăng ký'),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập thông tin này';
    }
    return null;
  }

  String? _urlValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;

    final uri = Uri.tryParse(value!.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return 'Vui lòng nhập URL hợp lệ';
    }
    return null;
  }
}

class _ShopTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  const _ShopTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: AppRadius.medium),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}

class _AddressPickerField extends StatelessWidget {
  final String? address;
  final VoidCallback? onTap;

  const _AddressPickerField({
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAddress = address != null && address!.trim().isNotEmpty;
    final borderColor = hasAddress
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : AppColors.borderLight);
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppRadius.medium,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasAddress
                  ? Icons.location_on_rounded
                  : Icons.add_location_alt_outlined,
              color: hasAddress ? AppColors.primary : mutedColor,
            ),
            AppSpacing.w8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAddress ? 'Địa chỉ shop' : 'Chọn địa chỉ shop',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    hasAddress
                        ? address!
                        : 'Tìm kiếm/chọn trên bản đồ để lấy tọa độ tự động',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ),
            AppSpacing.w8,
            Icon(Icons.chevron_right_rounded, color: mutedColor),
          ],
        ),
      ),
    );
  }
}
