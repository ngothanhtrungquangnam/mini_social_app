import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final int pageSize = 10;

  DocumentSnapshot? lastDocument;
  bool hasMore = true;

 
  Query _buildBaseQuery({bool filterByUser = false}) {
    Query query = _firestore.collection('posts');

    // 👉 PHẦN WHERE BẠN ĐANG TÌM Ở ĐÂY:
    if (filterByUser) {
      final user = _auth.currentUser;
      if (user != null) {
        // Lọc: Chỉ lấy bài viết có userId trùng với người đang đăng nhập
        query = query.where('userId', isEqualTo: user.uid);
      }
    }

    // Luôn luôn sắp xếp và giới hạn
    return query.orderBy('createdAt', descending: true).limit(pageSize);
  }

  // 1. Hàm tạo bài viết (Giữ nguyên)
  Future<void> addPost({required String content}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập.');

    await _firestore.collection('posts').add({
      'userId': user.uid,
      'email': user.email,
      'content': content,
      'likeCount': 0,
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Tải trang đầu (Cập nhật để dùng _buildBaseQuery)
  Future<List<DocumentSnapshot>> getFirstPage(
      {bool filterByUser = false}) async {
    lastDocument = null;
    hasMore = true;

    try {
      // Gọi hàm cơ sở để lấy query có (hoặc không có) WHERE
      QuerySnapshot snapshot =
          await _buildBaseQuery(filterByUser: filterByUser).get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        if (snapshot.docs.length < pageSize) hasMore = false;
      } else {
        hasMore = false;
      }
      return snapshot.docs;
    } catch (e) {
      print("Lỗi tải trang đầu: $e");
      return [];
    }
  }

  // 3. Tải trang tiếp theo (Cập nhật để dùng _buildBaseQuery)
  Future<List<DocumentSnapshot>> getNextPage(
      {bool filterByUser = false}) async {
    if (!hasMore || lastDocument == null) return [];

    try {
      // Gọi hàm cơ sở và thêm startAfterDocument
      Query query = _buildBaseQuery(filterByUser: filterByUser)
          .startAfterDocument(lastDocument!);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        if (snapshot.docs.length < pageSize) hasMore = false;
      } else {
        hasMore = false;
      }
      return snapshot.docs;
    } catch (e) {
      print("Lỗi tải trang tiếp: $e");
      return [];
    }
  }

  // (Tùy chọn) Stream cho Real-time nếu muốn demo
  Stream<QuerySnapshot> getPostsStream({bool filterByUser = false}) {
    return _buildBaseQuery(filterByUser: filterByUser).snapshots();
  }
}
