import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/main.dart';

class ProfileScreen extends StatefulWidget {
  final AuthController controller;
  const ProfileScreen({super.key, required this.controller});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isSellerMode = false;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? user?.email ?? "Người dùng";

    final bool isDarkMode = themeProvider.currTheme == ThemeMode.dark;

    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;

    // Sử dụng LayoutBuilder để lấy độ rộng màn hình thực tế (ví dụ: 320px)
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        // Tính toán tỉ lệ font chữ thông minh dựa trên màn hình
        double baseFontSize = screenWidth < 360 ? 12.0 : 14.0;
        double titleFontSize = screenWidth < 360 ? 14.0 : 16.0;
        double headerFontSize = screenWidth < 360 ? 18.0 : 22.0;

        return Scaffold(
          backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFF5F7FA),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // --- 1. HEADER XANH DƯƠNG (CHỐNG TRÀN CHỮ) ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      top: 60,
                      bottom: 30,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0056D2),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: screenWidth < 360 ? 65 : 80,
                        height: screenWidth < 360 ? 65 : 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue.shade100, width: screenWidth < 360 ? 2 : 4),
                        ),
                        child: Center(
                          child: isSellerMode
                              ? Icon(Icons.storefront_rounded, size: screenWidth < 360 ? 32 : 42, color: const Color(0xFF0056D2))
                              : Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
                            style: TextStyle(fontSize: screenWidth < 360 ? 30 : 40, fontWeight: FontWeight.bold, color: const Color(0xFF0056D2)),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth < 360 ? 12 : 20),
                      // Dùng Expanded bao bọc để block chữ tự động co giãn theo chiều ngang còn lại
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSellerMode ? "Shop Của Tôi" : displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis, // Nếu tên quá dài sẽ tự động biến thành dấu "..." thay vì tràn
                              style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            // Dùng Row bọc FittedBox hoặc Wrap để badge xác thực tự thu nhỏ vừa vặn
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade800.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Đã xác thực",
                                        style: TextStyle(color: Colors.white, fontSize: screenWidth < 360 ? 11 : 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(screenWidth < 360 ? 12.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 2. CARD CHẾ ĐỘ HIỂN THỊ ---
                      _buildCard(
                        cardColor: cardColor,
                        isDarkMode: isDarkMode,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Chế độ hiển thị", style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize, color: textColor)),
                                  const SizedBox(height: 4),
                                  RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      text: "Đang dùng: ",
                                      style: TextStyle(color: subTextColor, fontSize: baseFontSize),
                                      children: [
                                        TextSpan(
                                          text: isSellerMode ? "Người bán" : "Người mua",
                                          style: const TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                              onPressed: () {
                                setState(() {
                                  isSellerMode = !isSellerMode;
                                });
                              },
                              child: Text(
                                isSellerMode ? "BUYER" : "SELLER", // Rút ngắn text trên màn nhỏ để nút không lấn dòng
                                style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF0056D2), fontSize: baseFontSize),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenWidth < 360 ? 16 : 25),

                      // --- 3. ĐỔI LOGIC BODY THEO CHẾ ĐỘ ---
                      if (!isSellerMode) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                          child: Text("ĐƠN MUA CỦA TÔI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize, color: textColor, letterSpacing: 0.5)),
                        ),
                        _buildCard(
                          cardColor: cardColor,
                          isDarkMode: isDarkMode,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Truyền baseFontSize vào các icon để quản lý font chữ đồng bộ
                              _buildOrderIcon(CupertinoIcons.time, "Chờ xác nhận", isDarkMode, baseFontSize, screenWidth),
                              _buildOrderIcon(CupertinoIcons.cube_box, "Đang giao", isDarkMode, baseFontSize, screenWidth),
                              _buildOrderIcon(CupertinoIcons.check_mark_circled, "Hoàn thành", isDarkMode, baseFontSize, screenWidth),
                            ],
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                          child: Text("QUẢN LÝ CỬA HÀNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize, color: textColor, letterSpacing: 0.5)),
                        ),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: screenWidth < 360 ? 12 : 16,
                          crossAxisSpacing: screenWidth < 360 ? 12 : 16,
                          childAspectRatio: 1.3,
                          children: [
                            _buildSellerGridItem(Icons.add, Colors.blue, "Đăng sản phẩm", isDarkMode, cardColor, textColor, baseFontSize),
                            _buildSellerGridItem(Icons.storefront_outlined, Colors.orange, "Sản phẩm", isDarkMode, cardColor, textColor, baseFontSize),
                            _buildSellerGridItem(CupertinoIcons.list_bullet, Colors.purple, "Đơn hàng mới", isDarkMode, cardColor, textColor, baseFontSize),
                            _buildSellerGridItem(Icons.trending_up, Colors.green, "Doanh thu", isDarkMode, cardColor, textColor, baseFontSize),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.black45 : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Trang hiển thị Shop", style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize + 1, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Xem giao diện khách hàng",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white60, fontSize: baseFontSize - 1),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.8), size: 22),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: screenWidth < 360 ? 16 : 25),

                      // --- 4. CARD TIỆN ÍCH KHÁC ---
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                        child: Text("TIỆN ÍCH KHÁC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize, color: textColor, letterSpacing: 0.5)),
                      ),
                      _buildCard(
                        cardColor: cardColor,
                        isDarkMode: isDarkMode,
                        child: Column(
                          children: [
                            _buildMenuOption(
                              icon: CupertinoIcons.tickets,
                              iconColor: Colors.blue,
                              title: "Trung tâm hỗ trợ",
                              isDarkMode: isDarkMode,
                              fontSize: baseFontSize,
                              onTap: () {},
                            ),
                            Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[200], height: 20),

                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.amber.withValues(alpha: 0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                  color: isDarkMode ? Colors.amber : Colors.orange,
                                  size: screenWidth < 360 ? 18 : 22,
                                ),
                              ),
                              title: Text(
                                "Chế độ tối",
                                style: TextStyle(fontSize: baseFontSize, fontWeight: FontWeight.w500, color: textColor),
                              ),
                              trailing: Transform.scale(
                                scale: screenWidth < 360 ? 0.8 : 1.0, // Thu nhỏ nút gạt switch nếu màn hình quá hẹp
                                child: Switch(
                                  activeThumbColor: const Color(0xFF0056D2),
                                  value: isDarkMode,
                                  onChanged: (value) {
                                    themeProvider.toggleTheme();
                                  },
                                ),
                              ),
                            ),
                            Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[200], height: 20),

                            _buildMenuOption(
                              icon: Icons.logout,
                              iconColor: Colors.red,
                              title: "Đăng xuất tài khoản",
                              textColor: Colors.red,
                              isDarkMode: isDarkMode,
                              fontSize: baseFontSize,
                              onTap: () async {
                                await FirebaseAuth.instance.signOut();
                                widget.controller.logout();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({required Widget child, required bool isDarkMode, required Color cardColor}) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.transparent : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child
    );
  }

  Widget _buildSellerGridItem(IconData icon, Color color, String title, bool isDarkMode, Color cardColor, Color textColor, double fontSize) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: fontSize + 10),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderIcon(IconData icon, String label, bool isDarkMode, double fontSize, double screenWidth) {
    return Expanded( // Dùng Expanded chia đều không gian 3 cột, ép chữ nằm vừa vặn
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth < 360 ? 10 : 14),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: screenWidth < 360 ? 20 : 26, color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1, // SỬA: Giữ nguyên trên một dòng theo ý bạn
            overflow: TextOverflow.ellipsis, // Nếu chật quá sẽ tự động thu gọn bằng dấu ...
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize - 1, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
    required double fontSize,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: fontSize + 6),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: textColor ?? (isDarkMode ? Colors.white70 : Colors.black87),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}