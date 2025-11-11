// lib/screens/add_post_screen.dart

import 'package:flutter/material.dart';

import '../services/post_service.dart';

class AddPostScreen extends StatefulWidget {
 
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final PostService _postService = PostService();
  bool _isLoading = false;



  void _submitPost() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
    
      await _postService
          .addPost(content: _contentController.text.trim())
          .timeout(const Duration(seconds: 5), onTimeout: () {
        
        print("Firestore slow, but closing screen anyway.");
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Lỗi khi đăng bài: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng bài: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo Bài viết Mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Bạn đang nghĩ gì?',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitPost,
                    child: const Text('Đăng Bài'),
                  ),
          ],
        ),
      ),
    );
  }
}
