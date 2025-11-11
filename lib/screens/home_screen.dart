import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import 'add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();

  // Controller để lắng nghe sự kiện cuộn
  final ScrollController _scrollController = ScrollController();

  // Danh sách lưu trữ tất cả bài viết đã tải
  List<DocumentSnapshot> _posts = [];
  bool _isLoading = false; // Cờ để tránh tải đúp

  @override
  void initState() {
    super.initState();
    // 1. Tải trang đầu tiên khi màn hình khởi tạo
    _loadFirstPage();
    // 2. Thêm Listener cho sự kiện cuộn
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Hàm tải trang đầu tiên
  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
    });

    final newPosts = await _postService.getFirstPage();

    setState(() {
      _posts = newPosts;
      _isLoading = false;
    });
  }

  // Hàm tải trang tiếp theo (Pagination)
  void _loadNextPage() async {
    if (_isLoading || !_postService.hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final newPosts = await _postService.getNextPage();

    setState(() {
      _posts.addAll(newPosts);
      _isLoading = false;
    });
  }

  // Lắng nghe sự kiện cuộn để kích hoạt tải thêm
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Nếu cuộn đến cuối danh sách thì tải trang tiếp theo
      _loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed (Pagination)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        // Thêm tính năng kéo xuống để làm mới
        onRefresh: _loadFirstPage,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length +
              (_postService.hasMore ? 1 : 0), // Thêm 1 item cho loading spinner
          itemBuilder: (context, index) {
            // Hiển thị Loading Spinner ở cuối danh sách
            if (index == _posts.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final postData = _posts[index].data() as Map<String, dynamic>;

            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(postData['content'] ?? 'Bài viết trống',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Được đăng vào: ${postData['createdAt']?.toDate().toString() ?? 'N/A'}'),
                trailing: Text('Likes: ${postData['likeCount'] ?? 0}'),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Sau khi tạo bài viết, cần làm mới feed để thấy bài mới
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          ).then((_) => _loadFirstPage()); // Tải lại trang đầu sau khi quay lại
        },
      ),
    );
  }
}
