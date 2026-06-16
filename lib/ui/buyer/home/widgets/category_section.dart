import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

import '../../../../data/models/category_model.dart';

class CategorySection extends StatelessWidget {
  final bool isDark;
  final Future<List<CategoryModel>> categoriesFuture;
  final int selectedIndex;
  final Function(int index, int? categoryId) onCategorySelected;
  final VoidCallback onRetry;

  const CategorySection({
    super.key,
    required this.isDark,
    required this.categoriesFuture,
    required this.onCategorySelected,
    required this.selectedIndex,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            "Danh mục sản phẩm",
            style: AppTextStyles.headingLarge.copyWith(
              color: isDark
                  ? AppColors.textMutedLight
                  : AppColors.textMutedDark,
            ),
          ),
        ),
        AppSpacing.h16,
        FutureBuilder<List<CategoryModel>>(
          future: categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 44,
                child: Center(
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Không thể tải danh mục',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.red,
                        ),
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

            final List<CategoryModel> serverCategories = snapshot.data ?? [];

            return SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),

                itemCount: serverCategories.length + 1,
                itemBuilder: (context, index) {
                  final bool isSelected = selectedIndex == index;

                  String categoryName;
                  int? categoryId;

                  if (index == 0) {
                    categoryName = 'Tất cả';
                    categoryId = null;
                  } else {
                    final currCategory = serverCategories[index - 1];
                    categoryName = currCategory.name;
                    categoryId = currCategory.id;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => onCategorySelected(index, categoryId),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            categoryName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? AppColors.textLight
                                        : AppColors.textDark),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
