// Ngô Thành Trung -22KTMT1
// Nguyễn Văn Mùi -22KTMT2
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Import file cấu hình tự động sinh ra
import 'firebase_options.dart';

// Import AuthCheckScreen chính xác từ thư mục screens
import 'screens/auth_check_screen.dart';

void main() async {
  // Thêm try-catch để bắt lỗi khởi tạo Firebase nếu có
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Khởi tạo Firebase với cấu hình dành riêng cho nền tảng hiện tại
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('LỖI KHỞI TẠO FIREBASE: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Social App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Gọi AuthCheckScreen chính xác từ lib/screens
      home: AuthCheckScreen(),
    );
  }
}

// LƯU Ý QUAN TRỌNG:
// ĐỊNH NGHĨA WIDGET GIẢ ĐÃ BỊ XÓA KHỎI ĐÂY.
// Vui lòng đảm bảo bạn đã xóa class AuthCheckScreen giả (placeholder)
// khỏi cuối file main.dart nếu nó vẫn còn.
