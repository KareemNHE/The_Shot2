//views/widgets/post_card.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../viewmodels/post_interaction_viewmodel.dart';
import '../comment_section_screen.dart';
import '../post_share_screen.dart';
import '../profile_screen.dart';
import '../user_profile_screen.dart';
import 'custom_video_player.dart';
import 'video_post_card.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostInteractionViewModel>(
      create: (_) => PostInteractionViewModel(postId: post.id, postOwnerId: post.userId),
      child: Consumer<PostInteractionViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                        if (post.userId == currentUserId) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UserProfileScreen(userId: post.userId)),
                          );
                        }
                      },
                      child: CircleAvatar(
                        backgroundImage: post.userProfilePic.isNotEmpty
                            ? NetworkImage(post.userProfilePic)
                            : const AssetImage('assets/default_profile.png') as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                        print('---');
                        print('Post ID: ${post.id}');
                        print('Type: ${post.type}');
                        print('Image URL: ${post.imageUrl}');
                        print('Video URL: ${post.videoUrl}');
                        print('Thumbnail URL: ${post.thumbnailUrl}');
                        print('---');
                        if (post.userId == currentUserId) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UserProfileScreen(userId: post.userId)),
                          );
                        }
                      },
                      child: Text(
                        post.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to detail screen for videos
                  if (post.type == 'video') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPostDetailScreen(post: post),
                      ),
                    );
                  }
                },
                child: post.type == 'video' && post.videoUrl.isNotEmpty
                    ? VideoPostCard(post: post, isThumbnailOnly: true)
                    : post.imageUrl.isNotEmpty
                    ? Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Icon(Icons.broken_image)),
                    );
                  },
                )
                    : const SizedBox(
                  height: 200,
                  child: Center(child: Icon(Icons.broken_image)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  '${post.username}: ${post.caption}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        viewModel.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => viewModel.toggleLike(),
                    ),
                    Text('${viewModel.likeCount}'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            minChildSize: 0.4,
                            maxChildSize: 0.95,
                            expand: false,
                            builder: (context, scrollController) {
                              return CommentSectionSheet(
                                postId: post.id,
                                postOwnerId: post.userId,
                                scrollController: scrollController,
                              );
                            },
                          ),
                        );
                        await viewModel.init();
                      },
                    ),
                    Text('${viewModel.commentCount}'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            minChildSize: 0.4,
                            maxChildSize: 0.95,
                            expand: false,
                            builder: (context, scrollController) {
                              return PostShareScreen(
                                post: post,
                                scrollController: scrollController,
                              );
                            },
                          ),
                        );
                        await viewModel.init();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}

// New screen for video post details
class VideoPostDetailScreen extends StatelessWidget {
  final PostModel post;

  const VideoPostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Post')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            VideoPostCard(post: post, isThumbnailOnly: false),
            // Add additional post details or interactions here if needed
          ],
        ),
      ),
    );
  }
}