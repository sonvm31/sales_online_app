import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/ui/buyer/home/widgets/category_item.dart';

import '../../../../data/models/category_model.dart';

class CategorySection extends StatelessWidget {
  final bool isDark;
  final Future<List<CategoryModel>> categoriesFuture;
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final VoidCallback onRetry;

  const CategorySection({
    super.key,
    required this.isDark,
    required this.categoriesFuture,
    required this.onCategorySelected,
    required this.onRetry,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            "Danh mục",
            style: AppTextStyles.headingLarge.copyWith(
              color: isDark
                  ? AppColors.textMutedLight
                  : AppColors.textMutedDark,
            ),
          ),
        ),
        AppSpacing.h16,
        SizedBox(
          height: 44,
          child: FutureBuilder<List<CategoryModel>>(
            future: categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      AppSpacing.w8,
                      Text(
                        "Đang tải dữ liệu ... ",
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      Text(
                        "Lỗi tải danh mục!",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          CupertinoIcons.refresh,
                          color: AppColors.primary,
                        ),
                        onPressed: onRetry,
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      Text(
                        "Không có danh mục nào",
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              final categories = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryItem(
                    title: categories[index].name,
                    isSelected: selectedIndex == index,
                    onTap: () => onCategorySelected(index),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
