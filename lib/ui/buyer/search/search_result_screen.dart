import 'package:flutter/material.dart';
import 'package:sales_online_app/ui/buyer/search/controller/search_result_controller.dart';
import 'package:sales_online_app/ui/buyer/search/widgets/filter_sort_bar.dart';
import 'package:sales_online_app/ui/buyer/search/widgets/search_result_grid.dart';

import '../../../core/constants/app_styles.dart';

class SearchResultScreen extends StatefulWidget {
  final String keyword;

  const SearchResultScreen({super.key, required this.keyword});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late SearchResultController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SearchResultController(keyword: widget.keyword);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSearchBody(bool isDark) {
    if (_controller.errMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _controller.errMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _controller.fetchInitSearchResult,
              child: const Text("Thử lại"),
            ),
          ],
        ),
      );
    }

    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_controller.products.isEmpty) {
      return Center(
        child: Text(
          "Không tìm thấy sản phẩm nào phù hợp.",
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          SearchResultGrid(
            products: _controller.products,
            isLoadingMore: _controller.isLoadingMore,
          ),
          const SizedBox(height: 24)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, index) {
        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
          appBar: AppBar(
            title: Text("Kết quả cho '${widget.keyword}'"),
            elevation: 0,
          ),
          body: Column(
            children: [
              FilterSortBar(
                isDark: isDark,
                currSortType: _controller.currSortType,
                onSortChanged: _controller.updateSort,
                onFilterChanged: _controller.updatePriceFilter,
              ),
              Expanded(child: _buildSearchBody(isDark)),
            ],
          ),
        );
      },
    );
  }
}
