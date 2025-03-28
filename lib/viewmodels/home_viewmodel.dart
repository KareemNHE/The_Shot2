
//viewmodel/home_viewmodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/post_models.dart';

class HomeViewModel extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = true;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  HomeViewModel() {
    fetchPosts();
  }

  Future<void> addPost(PostModel post) async {
    _posts.insert(0, post); // Add the new post at the top
    notifyListeners();
  }


  Future<void> fetchPosts() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("User is not authenticated.");
    } else {
      print("Fetching posts for UID: $uid");
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch posts from the specific user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid) // Fetch posts for the logged-in user
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No posts found!');
      } else {
        print('Fetched ${querySnapshot.docs.length} posts!');
      }

      _posts = querySnapshot.docs
          .map((doc) => PostModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching posts: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  //unction to get followed user IDs
  Future<List<String>> getFollowedUserIds() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return [];
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
