import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/ui/buyer/home/controller/home_controller.dart';
import 'package:sales_online_app/ui/buyer/home/widgets/category_section.dart';
import 'package:sales_online_app/ui/buyer/home/widgets/home_header.dart';
import 'package:sales_online_app/ui/buyer/home/widgets/product_section.dart';
import 'package:sales_online_app/ui/buyer/search/search_history_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    _controller.loadAllData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Column(
          children: [
            HomeHeader(
              onSearchTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchHistoryScreen(),
                  ),
                );
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _controller.loadAllData(),
                color: AppColors.primary,
                backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
                child: SingleChildScrollView(
                  controller: _controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      CategorySection(
                        isDark: isDark,
                        categoriesFuture: _controller.categoriesFuture,
                        selectedIndex: _controller.selectedCategoryIndex,
                        onCategorySelected: _controller.changeCategoryIndex,
                        onRetry: _controller.loadCategories,
                      ),
                      const SizedBox(height: 24),
                      ProductSection(
                        isDark: isDark,
                        products: _controller.products,
                        isLoadingMore: _controller.isLoadingMore,
                        isLoadingProducts: _controller.isLoadingProducts,
                        onRetry: _controller.fetchInitProducts,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
