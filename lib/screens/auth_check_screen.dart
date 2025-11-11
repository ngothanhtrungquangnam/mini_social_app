import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'home_screen.dart'; // Màn hình chính (sẽ tạo sau)
import 'login_screen.dart'; // Màn hình đăng nhập (sẽ tạo sau)

class AuthCheckScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Lắng nghe trạng thái đăng nhập Real-time
      stream: _authService.userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Đang chờ kết nối/xác định trạng thái
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Nếu có User (đã đăng nhập)
        if (snapshot.hasData) {
          return HomeScreen(); // Chuyển đến màn hình chính
        } else {
          // Chưa đăng nhập
          return LoginScreen(); // Chuyển đến màn hình đăng nhập
        }
      },
    );
  }
}
