// viewmodels/profile_viewmodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_shot2/models/post_model.dart';

class ProfileViewModel extends ChangeNotifier {
  String _username = '';
  String _profilePictureUrl = '';
  String _bio = '';
  int _followersCount = 0;
  int _followingCount = 0;
  List<PostModel> _userPosts = [];
  bool _isLoading = true;


  String get username => _username;
  String get profilePictureUrl => _profilePictureUrl;
  String get bio => _bio;
  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
  List<PostModel> get userPosts => _userPosts;
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
          _bio = (data['bio'] ?? '').isNotEmpty ? data['bio'] : '';

          // Fetch counts directly from subcollections (for consistency with other profiles)
          final followersSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('followers')
              .get();
          final followingSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('following')
              .get();

          _followersCount = followersSnapshot.size;
          _followingCount = followingSnapshot.size;

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

      _userPosts = postsSnapshot.docs.map((doc) {
        return PostModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      print("Fetched ${_userPosts.length} posts");
      notifyListeners();
    } catch (e) {
      print('Error fetching user posts: $e');
    }
  }
}
