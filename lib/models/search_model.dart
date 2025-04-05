//models/search_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String imageUrl;
  final String caption;
  final String category;
  final Timestamp timestamp;

  Post({
    required this.imageUrl,
    required this.caption,
    required this.category,
    required this.timestamp,
  });
}

class SearchUser {
  final String username;
  final String first_name;
  final String last_name;
  final String profile_picture;

  SearchUser({
    required this.username,
    required this.first_name,
    required this.last_name,
    required this.profile_picture,
  });
}
