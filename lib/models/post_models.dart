//models/post_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String username;
  final String userProfilePic;
  final String imageUrl;
  final String caption;
  final DateTime timestamp;
  final List<String> hashtags;
  final String category;

  PostModel({
    required this.id,
    required this.username,
    required this.userProfilePic,
    required this.imageUrl,
    required this.caption,
    required this.timestamp,
    required this.hashtags,
    required this.category,
  });

  // Convert Firestore document to PostModel
  factory PostModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PostModel(
      id: id,
      username: data['username'] ?? 'Unknown User',
      userProfilePic: data['userProfilePic'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      hashtags: List<String>.from(data['hashtags'] ?? []),
      category: data['category'] ?? 'Uncategorized',
    );
  }
}
