// viewmodels/profile_viewmodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  String _username = '';
  String _profilePictureUrl = '';
  String _bio = '';
  int _followersCount = 0;
  int _followingCount = 0;
  List<String> _userPosts = [];
  bool _isLoading = true;

  String get username => _username;
  String get profilePictureUrl => _profilePictureUrl;
  String get bio => _bio;
  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
  List<String> get userPosts => _userPosts;
  bool get isLoading => _isLoading;

  Future<void> fetchUserProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() ?? {};

          _username = data['username'] ?? user.email!;
          _profilePictureUrl = data['profile_picture']?.isNotEmpty == true
              ? data['profile_picture']
              : 'assets/default_profile.png';
          print('Fetched bio: ${data['bio']}');
          _bio = (data['bio'] ?? '').isNotEmpty ? data['bio'] : '';
          _followersCount = data['followersCount'] ?? 0;
          _followingCount = data['followingCount'] ?? 0;

          await fetchUserPosts(user.uid);
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchUserPosts(String userId) async {
    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      _userPosts = postsSnapshot.docs
          .map((doc) => doc['imageUrl'] as String)
          .toList();

      notifyListeners();

      print("Fetched ${_userPosts.length} posts: $_userPosts"); // <-- ADD THIS
      notifyListeners();
    } catch (e) {
      print('Error fetching user posts: $e');
    }
  }
}
