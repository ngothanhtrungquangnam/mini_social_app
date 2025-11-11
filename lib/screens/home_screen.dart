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

  
  final ScrollController _scrollController = ScrollController();

  
  List<DocumentSnapshot> _posts = [];
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    
    _loadFirstPage();
    
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  
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

  
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
     
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
        
        onRefresh: _loadFirstPage,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length +
              (_postService.hasMore ? 1 : 0), 
          itemBuilder: (context, index) {
            
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
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          ).then((_) => _loadFirstPage()); 
        },
      ),
    );
  }
}
