import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'home_screen.dart'; 
import 'login_screen.dart'; 

class AuthCheckScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      
      stream: _authService.userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        
        if (snapshot.hasData) {
          return HomeScreen(); 
        } else {
          
          return LoginScreen(); 
        }
      },
    );
  }
}
