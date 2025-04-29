// viewmodels/search_viewmodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_shot2/models/search_model.dart';
import 'package:the_shot2/services/api_service.dart';
import 'package:the_shot2/models/post_model.dart';

class SearchViewModel extends ChangeNotifier {
  final ApiService apiService;

  SearchViewModel({required this.apiService});

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  List<PostModel> _allPosts = [];
  List<SearchUser> _allUsers = [];

  List<PostModel> _filteredPosts = [];
  List<SearchUser> _filteredUsers = [];

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  List<PostModel> get allPosts => _filteredPosts;
  List<SearchUser> get filteredUsers => _filteredUsers;

  Future<void> fetchAllUserPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('posts')
          .orderBy('timestamp', descending: true)
          .get();

      List<PostModel> tempPosts = postsSnapshot.docs.map((doc) {
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

      final Map<String, dynamic> userMap = {
        for (var user in usersSnapshot.docs) user.id: user.data(),
      };

      _allPosts = tempPosts.map((post) {
        final userData = userMap[post.userId];
        return PostModel(
          id: post.id,
          userId: post.userId,
          username: userData?['username'] ?? 'Unknown',
          userProfilePic: userData?['profile_picture'] ?? '',
          imageUrl: post.imageUrl,
          videoUrl: post.videoUrl,
          thumbnailUrl: post.thumbnailUrl,
          caption: post.caption,
          timestamp: post.timestamp,
          hashtags: post.hashtags,
          category: post.category,
          type: post.type,
        );
      }).toList();

      _filteredPosts = List.from(_allPosts);
      _filteredUsers = List.from(_allUsers);
    } catch (e) {
      _errorMessage = 'Failed to refresh posts: $e';
      print('Error fetching search posts: $e');
    }

    if (isRefresh) {
      _isRefreshing = false;
    } else {
      _isLoading = false;
    }
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}