// viewmodels/search_viewmodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_shot2/models/search_model.dart';
import 'package:the_shot2/services/api_service.dart';

class SearchViewModel extends ChangeNotifier {
  final ApiService apiService;

  SearchViewModel({required this.apiService});

  bool _isLoading = true;

  List<Post> _allPosts = [];
  List<SearchUser> _allUsers = [];

  List<Post> _filteredPosts = [];
  List<SearchUser> _filteredUsers = [];

  bool get isLoading => _isLoading;
  List<Post> get allPosts => _filteredPosts;
  List<SearchUser> get filteredUsers => _filteredUsers;

  Future<void> fetchAllUserPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch all posts
      final postsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('posts')
          .orderBy('timestamp', descending: true)
          .get();

      _allPosts = postsSnapshot.docs.map((doc) {
        return Post(
          imageUrl: doc['imageUrl'],
          caption: doc['caption'],
          category: doc['category'] ?? '',
          timestamp: doc['timestamp'],
        );
      }).toList();

      // Fetch all users
      final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      _allUsers = usersSnapshot.docs.map((doc) {
        return SearchUser(
          username: doc['username'] ?? '',
          first_name: doc['first_name'] ?? '',
          last_name: doc['last_name'] ?? '',
          profile_picture: doc['profile_picture'] ?? '',
        );
      }).toList();

      // Show all by default
      _filteredPosts = List.from(_allPosts);
      _filteredUsers = [];

    } catch (e) {
      print('Error fetching data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.isEmpty) {
      _filteredPosts = List.from(_allPosts);
      _filteredUsers = [];
    } else {
      _filteredPosts = _allPosts.where((post) {
        return post.caption.toLowerCase().contains(lowerQuery) ||
            post.category.toLowerCase().contains(lowerQuery) ||
            post.caption.toLowerCase().contains('#$lowerQuery');
      }).toList();

      _filteredUsers = _allUsers.where((user) {
        return user.username.toLowerCase().contains(lowerQuery) ||
            user.first_name.toLowerCase().contains(lowerQuery) ||
          user.last_name.toLowerCase().contains(lowerQuery);

      }).take(5).toList();
    }

    notifyListeners();
  }
}