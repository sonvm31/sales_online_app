import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sales_online_app/main.dart';
import 'package:sales_online_app/core/network/api_config.dart';
class SellerReportScreen extends StatelessWidget {
  final dynamic shopId;

  const SellerReportScreen({super.key, required this.shopId});

  Future<Map<String, dynamic>> _fetchReportData(dynamic id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/orders/shop/$id/revenue');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          "monthlyRevenue": "${responseData['monthlyRevenue'] ?? '0'}đ",
          "revenueGrowth": responseData['revenueGrowth'] ?? "+0% so với tháng trước",
          "newOrders": responseData['newOrders'] ?? 0,
          "soldProducts": responseData['soldProducts'] ?? 0,
          "weeklyChartData": List<double>.from(responseData['weeklyChartData'] ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
        };
      } else {
        throw Exception('Lỗi server: Mã lỗi ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến Backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = themeProvider.currTheme == ThemeMode.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Thống kê doanh thu",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchReportData(shopId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Có lỗi xảy ra khi tải dữ liệu", style: TextStyle(color: textColor)));
          }

          final data = snapshot.data!;
          final List<double> chartValues = List<double>.from(data["weeklyChartData"]);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.attach_money_rounded, color: Colors.white70, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        "Doanh thu tháng này",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data["monthlyRevenue"],
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              data["revenueGrowth"],
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildSubStatCard(
                        cardColor: cardColor,
                        textColor: textColor,
                        icon: Icons.list_alt_rounded,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF3B82F6),
                        value: "${data["newOrders"]}",
                        label: "Đơn hàng mới",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSubStatCard(
                        cardColor: cardColor,
                        textColor: textColor,
                        icon: Icons.token_outlined,
                        iconBg: const Color(0xFFFFF7ED),
                        iconColor: const Color(0xFFF97316),
                        value: "${data["soldProducts"]}",
                        label: "Sản phẩm đã bán",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.0 : 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Biểu đồ doanh thu (7 ngày)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (index) {
                            final days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
                            return _buildBarChartColumn(
                              value: chartValues[index],
                              dayLabel: days[index],
                              textColor: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubStatCard({
    required Color cardColor,
    required Color textColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBarChartColumn({required double value, required String dayLabel, required Color textColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(dayLabel, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}