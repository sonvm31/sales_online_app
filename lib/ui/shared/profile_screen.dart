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
  bool isSellerMode = false; // Biến trạng thái switch chế độ BUYER/SELLER

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? user?.email ?? "Người dùng";

    // Đồng bộ trạng thái Dark Mode từ hệ thống
    final bool isDarkMode = themeProvider.currTheme == ThemeMode.dark;

    // Định nghĩa màu sắc động thích ứng theo Theme
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- 1. HEADER XANH DƯƠNG CHUẨN UI ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0056D2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                children: [
                  // Icon tròn thay đổi theo chế độ
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade100, width: 4),
                    ),
                    child: Center(
                      child: isSellerMode
                          ? const Icon(Icons.storefront_rounded, size: 42, color: Color(0xFF0056D2))
                          : Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF0056D2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Tên hiển thị linh hoạt theo thiết kế
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSellerMode ? "Shop Của Tôi" : displayName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF00E676), size: 16),
                            SizedBox(width: 6),
                            Text("Đã xác thực", style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Chế độ hiển thị", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                text: "Đang dùng: ",
                                style: TextStyle(color: subTextColor, fontSize: 14),
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
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isSellerMode = !isSellerMode; // Switch giao diện qua lại công bằng
                            });
                          },
                          child: Text(
                            isSellerMode ? "Chuyển sang BUYER" : "Chuyển sang SELLER",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0056D2)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- 3. ĐỔI LOGIC BODY THEO ISSELLERMODE ---
                  if (!isSellerMode) ...[
                    // GIAO DIỆN BUYER (ĐƠN MUA CỦA TÔI)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                      child: Text("ĐƠN MUA CỦA TÔI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor, letterSpacing: 0.5)),
                    ),
                    _buildCard(
                      cardColor: cardColor,
                      isDarkMode: isDarkMode,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOrderIcon(CupertinoIcons.time, "Chờ xác\nnhận", isDarkMode),
                          _buildOrderIcon(CupertinoIcons.cube_box, "Đang giao", isDarkMode),
                          _buildOrderIcon(CupertinoIcons.check_mark_circled, "Hoàn thành", isDarkMode),
                        ],
                      ),
                    ),
                  ] else ...[
                    // GIAO DIỆN SELLER (QUẢN LÝ CỬA HÀNG - LƯỚI 4 Ô)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                      child: Text("QUẢN LÝ CỬA HÀNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor, letterSpacing: 0.5)),
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildSellerGridItem(Icons.add, Colors.blue, "Đăng sản phẩm", isDarkMode, cardColor, textColor),
                        _buildSellerGridItem(Icons.storefront_outlined, Colors.orange, "Sản phẩm của tôi", isDarkMode, cardColor, textColor),
                        _buildSellerGridItem(CupertinoIcons.list_bullet, Colors.purple, "Đơn hàng mới", isDarkMode, cardColor, textColor),
                        _buildSellerGridItem(Icons.trending_up, Colors.green, "Doanh thu", isDarkMode, cardColor, textColor),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // CARD TRANG HIỂN THỊ SHOP (DARK BANNER)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.black45 : const Color(0xFF1E293B), // Màu đen titan sang trọng
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Trang hiển thị Shop", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                              SizedBox(height: 6),
                              Text("Xem giao diện khách hàng nhìn thấy", style: TextStyle(color: Colors.white60, fontSize: 13)),
                            ],
                          ),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white.withOpacity(0.8), size: 24),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),

                  // --- 4. CARD TIỆN ÍCH KHÁC (LUÔN CÓ VÀ ĐỒNG BỘ DARKMODE) ---
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                    child: Text("TIỆN ÍCH KHÁC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor, letterSpacing: 0.5)),
                  ),
                  _buildCard(
                    cardColor: cardColor,
                    isDarkMode: isDarkMode,
                    child: Column(
                      children: [
                        _buildMenuOption(
                          icon: CupertinoIcons.tickets,
                          iconColor: Colors.blue,
                          title: "Trung tâm hỗ trợ (Ticket)",
                          isDarkMode: isDarkMode,
                          onTap: () {},
                        ),
                        Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[200], height: 20),

                        // DÒNG DARK MODE HOẠT ĐỘNG THÔNG MINH
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.amber.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              color: isDarkMode ? Colors.amber : Colors.orange,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            "Chế độ tối (Dark Mode)",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
                          ),
                          trailing: Switch(
                            activeColor: const Color(0xFF0056D2),
                            value: isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                          ),
                        ),
                        Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[200], height: 20),

                        _buildMenuOption(
                          icon: Icons.logout,
                          iconColor: Colors.red,
                          title: "Đăng xuất tài khoản",
                          textColor: Colors.red,
                          isDarkMode: isDarkMode,
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
  }

  // Helper Khung Card
  Widget _buildCard({required Widget child, required bool isDarkMode, required Color cardColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Helper ô tính năng quản lý của Seller (Lưới 4 ô chuẩn ảnh)
  Widget _buildSellerGridItem(IconData icon, Color color, String title, bool isDarkMode, Color cardColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      ),
    );
  }

  // Helper Icon Đơn mua hàng (Buyer)
  Widget _buildOrderIcon(IconData icon, String label, bool isDarkMode) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 26, color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
      ],
    );
  }

  // Helper dòng Menu Option
  Widget _buildMenuOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor ?? (isDarkMode ? Colors.white70 : Colors.black87),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}