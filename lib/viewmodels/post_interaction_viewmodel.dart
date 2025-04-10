// viewmodels/post_interaction_viewmodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostInteractionViewModel extends ChangeNotifier {
  final String postId;
  bool isLiked = false;
  int likeCount = 0;
  int commentCount = 0;

  PostInteractionViewModel({required this.postId});

  Future<void> init() async {
    await _fetchLikes();
    await _fetchComments();
  }

  Future<void> _fetchLikes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final likeDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uid)
        .get();

    isLiked = likeDoc.exists;

    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .get();

    likeCount = snapshot.docs.length;
    notifyListeners();
  }

  Future<void> _fetchComments() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    commentCount = snapshot.docs.length;
    notifyListeners();
  }

  Future<void> toggleLike() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ref = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uid);

    if (isLiked) {
      await ref.delete();
      likeCount--;
    } else {
      await ref.set({'timestamp': FieldValue.serverTimestamp()});
      likeCount++;
    }

    isLiked = !isLiked;
    notifyListeners();
  }
}
