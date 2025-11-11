import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int pageSize = 10; // Giới hạn số lượng bài viết mỗi lần tải

  // Con trỏ để đánh dấu bài viết cuối cùng của trang trước
  DocumentSnapshot? lastDocument;
  bool hasMore = true; // Cờ báo hiệu còn dữ liệu để tải

  // 1. Hàm tạo bài viết mới (giữ nguyên)
  // Trong lib/services/post_service.dart

  Future<void> addPost({required String content}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Người dùng chưa đăng nhập.');
    }

    print("--- BẮT ĐẦU ĐĂNG BÀI ---"); // Log 1
    print("UserID: ${user.uid}");

    try {
      print("Đang gọi Firestore..."); // Log 2

      // Thêm timeout để không phải chờ mãi mãi (ví dụ 10 giây)
      await _firestore.collection('posts').add({
        'userId': user.uid,
        'email': user.email,
        'content': content,
        'likeCount': 0,
        'commentCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("Firestore Timeout: Mạng quá chậm hoặc bị chặn!");
      });

      print("--- ĐĂNG BÀI THÀNH CÔNG ---"); // Log 3
    } catch (e) {
      print("--- LỖI ĐĂNG BÀI: $e ---"); // Log Lỗi
      rethrow; // Ném lỗi ra ngoài để UI biết mà tắt loading
    }
  }

  // 2. Hàm Tải trang DỮ LIỆU ĐẦU TIÊN (Refresh)
  Future<List<DocumentSnapshot>> getFirstPage() async {
    // Reset trạng thái
    lastDocument = null;
    hasMore = true;

    // Tạo truy vấn phức hợp (Complex Query)
    Query query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    QuerySnapshot snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      // Lưu lại con trỏ cuối cùng
      lastDocument = snapshot.docs.last;
      // Kiểm tra nếu số lượng trả về ít hơn giới hạn thì là hết dữ liệu
      if (snapshot.docs.length < pageSize) {
        hasMore = false;
      }
    } else {
      hasMore = false;
    }

    return snapshot.docs;
  }

  // 3. Hàm Tải trang TIẾP THEO (Pagination)
  Future<List<DocumentSnapshot>> getNextPage() async {
    if (!hasMore || lastDocument == null) {
      return []; // Nếu hết dữ liệu hoặc chưa tải trang đầu tiên thì trả về rỗng
    }

    // Tạo truy vấn phức hợp: Bắt đầu TẢI SAU con trỏ của trang trước
    Query query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDocument!) // <-- Pagination logic
        .limit(pageSize);

    QuerySnapshot snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      // Cập nhật con trỏ mới
      lastDocument = snapshot.docs.last;
      if (snapshot.docs.length < pageSize) {
        hasMore = false;
      }
    } else {
      hasMore = false;
    }

    return snapshot.docs;
  }
}
