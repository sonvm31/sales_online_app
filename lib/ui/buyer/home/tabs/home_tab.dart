import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/services/category_service.dart';
import 'package:sales_online_app/ui/buyer/home/widgets/home_header.dart';
import 'package:sales_online_app/ui/buyer/home/widgets/product_section.dart';

import '../../../../data/models/category_model.dart';
import '../widgets/category_section.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _selectedIndex = 0;
  final CategoryService _categoryService = CategoryService();
  late Future<List<CategoryModel>> _categoryFuture;

  final List<Map<String, String>> _products = [
    {
      "name": "iPhone 15 Pro Max",
      "price": "29.990.000đ",
      "store": "Apple Store VN",
      "image": "",
    },
    {
      "name": "Samsung Galaxy S24 Ultra",
      "price": "31.990.000đ",
      "store": "Samsung Official",
      "image": "",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categoryFuture = _categoryService.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const HomeHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppSpacing.h24,
                CategorySection(
                  isDark: isDark,
                  categoriesFuture: _categoryFuture,
                  selectedIndex: _selectedIndex,
                  onCategorySelected: (index) =>
                      setState(() => _selectedIndex = index),
                  onRetry: _loadCategories,
                ),
                AppSpacing.h24,
                ProductSection(isDark: isDark, products: _products),
                AppSpacing.h24,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
