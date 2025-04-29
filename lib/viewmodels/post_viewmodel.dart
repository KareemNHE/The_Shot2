//viewmodel/post_viewmodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostViewModel extends ChangeNotifier {
  List<PostModel> _userPosts = [];
  bool _isLoading = true;

  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;

  // Fetch posts for a specific user (for profile)
  Future<void> fetchUserPosts(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      _userPosts = querySnapshot.docs
          .map((doc) => PostModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      print('Fetched ${_userPosts.length} posts for user $userId');
    } catch (e) {
      print('Error fetching user posts: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create a new post
  Future<void> createPost({
    required String userId,
    required String username,
    required String userProfilePic,
    required String imageUrl,
    required String caption,
  }) async {
    try {
      DocumentReference postRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('posts')
          .add({
        'username': username,
        'userProfilePic': userProfilePic,
        'imageUrl': imageUrl,
        'caption': caption,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Post created with ID: ${postRef.id}');
    } catch (e) {
      print('Error creating post: $e');
    }
  }
}
