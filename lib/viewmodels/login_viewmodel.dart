//viewmodels/login_viewmodel.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_shot2/user_auth/firebase_auth_implementation/firebase_auth_services.dart';

class LoginViewModel {
  final FirebaseAuthService _auth = FirebaseAuthService();

  // Fetch email using username
  Future<String?> getEmailFromUsername(String username) async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }
    return result.docs.first['email'];
  }

  // Login logic
  Future<User?> loginUser(String input, String password) async {
    String emailToUse = input;

    // Check if input is a username
    if (!input.contains('@')) {
      String? fetchedEmail = await getEmailFromUsername(input);
      if (fetchedEmail == null) {
        return null;
      }
      emailToUse = fetchedEmail;
    }

    User? user = await _auth.loginWithEmailAndPassword(emailToUse, password);
    return user;
  }
}
