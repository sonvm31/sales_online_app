import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/cart/cart_controller.dart';
import 'package:sales_online_app/ui/buyer/search/search_result_screen.dart';

class SearchHistoryScreen extends StatefulWidget {
  final CartController? cartController;
  final ValueChanged<int>? onTabSelected;

  const SearchHistoryScreen({
    super.key,
    this.cartController,
    this.onTabSelected,
  });

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _navigateToResults(String keyword) {
    if (keyword.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(
          keyword: keyword.trim(),
          cartController: widget.cartController,
          onTabSelected: widget.onTabSelected,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: isDark ? Colors.white : Colors.black26,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: Padding(
          padding: EdgeInsets.only(right: AppSpacing.md),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  Icons.search_outlined,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _navigateToResults,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black45,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: "Tìm sản phẩm, thương hiệu mong muốn...",
                      border: InputBorder.none,
                      isDense: true,
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _searchController.clear(),
                            child: Icon(
                              Icons.cancel_outlined,
                              color: isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                              size: 18,
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: const SizedBox.shrink(),
    );
  }
}
