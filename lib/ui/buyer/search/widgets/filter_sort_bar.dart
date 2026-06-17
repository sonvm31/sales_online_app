import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class FilterSortBar extends StatelessWidget {
  final bool isDark;
  final String currSortType;
  final Function(String sortType) onSortChanged;
  final Function(double? min, double? max) onFilterChanged;

  const FilterSortBar({
    super.key,
    required this.isDark,
    required this.currSortType,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  Widget _buildBarButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: isActive
            ? AppColors.primary
            : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final minController = TextEditingController();
    final maxController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lọc theo khoảng giá"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Giá tối thiểu (đ)"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: maxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Giá tối đa (đ)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final double? min = double.tryParse(minController.text);
              final double? max = double.tryParse(maxController.text);
              onFilterChanged(min, max);
              Navigator.pop(context);
            },
            child: const Text("Áp dụng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBarButton(
            label: "Giá Thấp - Cao",
            isActive: currSortType == "PRICE_ASC",
            onTap: () => onSortChanged("PRICE_ASC"),
          ),
          _buildBarButton(
            label: "Giá Cao - Thấp",
            isActive: currSortType == "PRICE_DESC",
            onTap: () => onSortChanged("PRICE_DESC"),
          ),
          InkWell(
            onTap: () => _showFilterDialog(context),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  size: 18,
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
