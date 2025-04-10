
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final followedIds = await getFollowedUserIds();
      followedIds.add(currentUserId); // include own posts

      List<PostModel> allFetchedPosts = [];

      for (final id in followedIds) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .get();

        allFetchedPosts.addAll(snapshot.docs.map((doc) =>
            PostModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)));
      }

      allFetchedPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _posts = allFetchedPosts;
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
