import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart'; // Import controller vào

class ProfileScreen extends StatelessWidget {
  final AuthController controller; // Khai báo nhận controller từ Wrapper truyền sang

  const ProfileScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user hiện tại từ Firebase
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? user?.email ?? "Người dùng";

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
                // 1. Đăng xuất khỏi Firebase
                await FirebaseAuth.instance.signOut();

                // 2. Gọi hàm logout của controller (nếu trong controller bạn của bạn có viết hàm tên khác như signOut, hoặc logout, hãy check lại trong file auth_controller.dart nhé)
                // Hàm này sẽ đổi trạng thái status về AuthStatus.unauthenticated
                controller.logout();

                // Vì AuthGate ở ngoài cùng đang lắng nghe controller này,
                // khi status thay đổi, AuthGate sẽ tự động đá user về màn hình LoginScreen chuẩn bài!
              },
            ),
          ],
        ),
      ),
    );
  }
}