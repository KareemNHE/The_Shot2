// viewmodels/create_post_viewmodel.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home_viewmodel.dart';

class CreatePostViewModel extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  CreatePostViewModel() {
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Post Uploaded',
      'Your post has been successfully uploaded.',
      platformChannelSpecifics,
    );
  }

  Future<void> createPost({
    required String imageUrl,
    required String caption,
    required String category,
    required BuildContext context,
    required HomeViewModel homeViewModel,
  }) async {
    final trimmedCaption = caption.trim();
    if (trimmedCaption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caption cannot be empty!')),
      );
      return;
    }

    List<String> extractHashtags(String caption) {
      final RegExp hashtagRegex = RegExp(r'\B#\w\w+');
      return hashtagRegex.allMatches(caption).map((match) => match.group(0)!).toList();
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print("Error: User is not logged in.");
        return;
      }

      final hashtags = extractHashtags(trimmedCaption);

      String finalImageUrl = imageUrl;
      if (!imageUrl.startsWith('https://')) {
        final file = File(imageUrl);
        if (!file.existsSync()) {
          throw Exception('Image file does not exist');
        }

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = await storageRef.putFile(file);
        finalImageUrl = await uploadTask.ref.getDownloadURL();
      }

      final postRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc();

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};

      final newPost = {
        'imageUrl': finalImageUrl,
        'caption': trimmedCaption,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
        'username': userData['username'] ?? '',
        'userProfilePic': userData['profile_picture'] ?? '',
        'hashtags': hashtags,
        'category': category,
      };


      await postRef.set(newPost);
      homeViewModel.fetchPosts();
      await showNotification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    } catch (e) {
      print('Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    }
  }
}
