
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart';
import '../screens/task_list_screen.dart';

class AuthService {
  handleAuthState() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return TaskListScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }

  signOut() {
    FirebaseAuth.instance.signOut();
  }
}
