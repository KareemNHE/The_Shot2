//views/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../models/notification_model.dart';
import 'post_detail_screen.dart';
import 'user_profile_screen.dart';
import 'widgets/notification_tile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: () {
                Provider.of<NotificationViewModel>(context, listen: false).markAllAsRead();
              },
            ),
          ],
        ),
        body: Consumer<NotificationViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final notifications = viewModel.notifications;

            if (notifications.isEmpty) {
              return const Center(child: Text("No notifications yet."));
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isUnread = !notification.isRead;

                return NotificationTile(
                  notification: notification,
                  onTap: () {
                    Provider.of<NotificationViewModel>(context, listen: false)
                        .markAsRead(notification.id);

                    if (notification.type == 'like' || notification.type == 'comment' || notification.type == 'tag') {
                      if (notification.relatedPostId != null && notification.postOwnerId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(
                              postId: notification.relatedPostId,
                              postOwnerId: notification.postOwnerId,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Post not found.")),
                        );
                      }
                    } else if (notification.type == 'follow') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfileScreen(userId: notification.senderId),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _getNotificationText(AppNotification notification) {
    switch (notification.type) {
      case 'like':
        return '${notification.senderUsername} liked your post.';
      case 'comment':
        return '${notification.senderUsername} commented on your post.';
      case 'follow':
        return '${notification.senderUsername} followed you.';
      case 'tag':
        return '${notification.senderUsername} tagged you in a post.';
      case 'follow_request':
        return '${notification.senderUsername} requested to follow you.';
      default:
        return 'You have a new notification.';
    }
  }

  String _formatTime(DateTime time) {
    final duration = DateTime.now().difference(time);
    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inHours < 1) return '${duration.inMinutes}m ago';
    if (duration.inDays < 1) return '${duration.inHours}h ago';
    return '${duration.inDays}d ago';
  }
}
