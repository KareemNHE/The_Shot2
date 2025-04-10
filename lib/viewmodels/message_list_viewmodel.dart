//viewmodels/message_list_viewmodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/search_model.dart';

class ChatSummary {
  final String receiverId;
  final String receiverUsername;
  final String receiverProfilePic;
  final String? lastMessage;

  ChatSummary({
    required this.receiverId,
    required this.receiverUsername,
    required this.receiverProfilePic,
    this.lastMessage,
  });
}

class MessageListViewModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<ChatSummary> recentChats = [];
  List<SearchUser> searchedUsers = [];
  bool isSearching = false;

  Future<void> loadChats() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    // Get all unique users this user has messaged
    final sent = await _firestore
        .collection('messages')
        .where('senderId', isEqualTo: currentUserId)
        .get();

    final received = await _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .get();

    final userIds = <String>{};

    for (var doc in sent.docs) {
      userIds.add(doc['receiverId']);
    }
    for (var doc in received.docs) {
      userIds.add(doc['senderId']);
    }

    final List<ChatSummary> chats = [];

    for (final uid in userIds) {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      // Get the most recent message with this user
      final messagesQuery = await _firestore
          .collection('messages')
          .where('senderId', whereIn: [currentUserId, uid])
          .where('receiverId', whereIn: [currentUserId, uid])
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final lastMessage = messagesQuery.docs.isNotEmpty
          ? messagesQuery.docs.first['text'] as String
          : '';

      chats.add(ChatSummary(
        receiverId: uid,
        receiverUsername: userData['username'] ?? 'Unknown',
        receiverProfilePic: userData['profile_picture'] ?? '',
        lastMessage: lastMessage,
      ));
    }

    recentChats = chats;
    notifyListeners();
  }

  void searchUsers(String query) async {
    isSearching = query.isNotEmpty;

    if (query.isEmpty) {
      searchedUsers = [];
      notifyListeners();
      return;
    }

    final snapshot = await _firestore.collection('users').get();

    final results = snapshot.docs.map((doc) {
      final data = doc.data();
      return SearchUser(
        id: doc.id,
        username: data['username'] ?? '',
        first_name: data['first_name'] ?? '',
        last_name: data['last_name'] ?? '',
        profile_picture: data['profile_picture'] ?? '',
      );
    }).where((user) {
      final lowerQuery = query.toLowerCase();
      return user.username.toLowerCase().contains(lowerQuery) ||
          user.first_name.toLowerCase().contains(lowerQuery) ||
          user.last_name.toLowerCase().contains(lowerQuery);
    }).toList();

    searchedUsers = results;
    notifyListeners();
  }
}
