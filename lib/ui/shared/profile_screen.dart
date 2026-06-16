import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:sales_online_app/core/theme/theme_provider.dart'; // Không cần import nếu đã có trong main.dart và sử dụng biến toàn cục
import 'package:sales_online_app/main.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController controller; // Khai báo nhận controller từ Wrapper truyền sang

  const ProfileScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user hiện tại từ Firebase
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? user?.email ?? "Người dùng";
    final isDarkMode = themeProvider.currTheme == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài khoản của tôi"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.person_crop_circle, size: 80, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
                      child: Text(
                        "Tiện ích khác",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                    const Divider(),

                    // công tắc gạt Switch chuyển Theme
                    ListTile(
                      leading: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: isDarkMode ? Colors.amber : Colors.blue,
                      ),
                      title: const Text("Chế độ tối (Dark Mode)"),
                      trailing: Switch(
                        value: isDarkMode, // Bật công tắc nếu đang là chế độ tối
                        onChanged: (value) {
                          // 3. Gọi trực tiếp hàm toggleTheme() từ biến toàn cục themeProvider
                          themeProvider.toggleTheme();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Nút Logout
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Đăng xuất", style: TextStyle(fontSize: 16)),
              onPressed: () async {

                await FirebaseAuth.instance.signOut();

                controller.logout();

              },
            ),
          ],
        ),
      ),
    );
  }
}