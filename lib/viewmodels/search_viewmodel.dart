// viewmodels/search_viewmodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_shot2/models/search_model.dart';
import 'package:the_shot2/services/api_service.dart';
import 'package:the_shot2/models/post_models.dart';


class SearchViewModel extends ChangeNotifier {
  final ApiService apiService;

  SearchViewModel({required this.apiService});

  bool _isLoading = true;

  List<PostModel> _allPosts = [];
  List<SearchUser> _allUsers = [];

  List<PostModel> _filteredPosts = [];
  List<SearchUser> _filteredUsers = [];

  bool get isLoading => _isLoading;
  List<PostModel> get allPosts => _filteredPosts;
  List<SearchUser> get filteredUsers => _filteredUsers;

  Future<void> fetchAllUserPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('posts')
          .orderBy('timestamp', descending: true)
          .get();

      _allPosts = postsSnapshot.docs.map((doc) {
        return PostModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

      _allUsers = usersSnapshot.docs.map((doc) {
        return SearchUser(
          id: doc.id,
          username: doc['username'] ?? '',
          first_name: doc['first_name'] ?? '',
          last_name: doc['last_name'] ?? '',
          profile_picture: doc['profile_picture'] ?? '',
        );
      }).toList();

      _filteredPosts = List.from(_allPosts);
      _filteredUsers = [];
    } catch (e) {
      print('Error fetching search posts: $e');
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
            post.category.toLowerCase().contains(lowerQuery);
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