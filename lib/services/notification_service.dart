import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> createNotification({
    required String recipientId,
    required String type,
    String? relatedPostId,
    String? postOwnerId,
    String? extraMessage,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid == recipientId) return;

    final senderSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();
    final senderData = senderSnapshot.data();

    final newNotification = {
      'type': type,
      'senderId': currentUser.uid,
      'senderUsername': senderData?['username'] ?? 'Someone',
      'senderProfilePic': senderData?['profile_picture'] ?? '',
      'relatedPostId': relatedPostId,
      'postOwnerId': postOwnerId,
      'message': extraMessage,
      'timestamp': Timestamp.now(),
      'isRead': false,
    };

    await _firestore
        .collection('users')
        .doc(recipientId)
        .collection('notifications')
        .add(newNotification);
  }
}
