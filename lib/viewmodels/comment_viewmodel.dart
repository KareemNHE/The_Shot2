// viewmodels/comment_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';
import '../services/notification_service.dart';

class CommentViewModel extends ChangeNotifier {
  final String postId;
  List<CommentModel> _comments = [];
  bool _isLoading = true;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  final String postOwnerId;

  CommentViewModel({
    required this.postId,
    required this.postOwnerId,
  }) {
    fetchComments();
  }


  Future<void> fetchComments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      _comments =
          snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching comments: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addComment(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = userDoc.data() ?? {};

    final commentData = {
      'userId': user.uid,
      'username': userData['username'] ?? user.email,
      'userProfilePic': userData['profile_picture'] ?? '',
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(commentData);

    await fetchComments(); // Refresh after adding
    await NotificationService.createNotification(
      recipientId: postOwnerId,
      type: 'comment',
      relatedPostId: postId,
      postOwnerId: postOwnerId,
    );
  }
}
