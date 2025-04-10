//viewmodels/chat_viewmodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';

class ChatViewModel extends ChangeNotifier {
  final String otherUserId;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<MessageModel> messages = [];
  bool isLoading = true;

  ChatViewModel({required this.otherUserId}) {
    _listenToMessages();
  }

  void _listenToMessages() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .where('senderId', whereIn: [currentUserId, otherUserId])
        .where('receiverId', whereIn: [currentUserId, otherUserId])
        .snapshots()
        .listen((snapshot) {
      messages = snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String text) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || text.trim().isEmpty) return;

    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      receiverId: otherUserId,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    await _firestore.collection('messages').add(message.toMap());
  }
}
