//views/widgets/post_card.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_models.dart';
import '../../viewmodels/post_interaction_viewmodel.dart';
import '../comment_section_screen.dart';
import '../post_detail_screen.dart';
import '../post_share_screen.dart';
import '../profile_screen.dart';
import '../user_profile_screen.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostInteractionViewModel>(
      create: (_) => PostInteractionViewModel(postId: post.id)..init(),
      child: Consumer<PostInteractionViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username & profile pic above image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                        if (post.userId == currentUserId) {
                          // Navigate to self profile screen (same as bottom nav one)
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        } else {
                          // Navigate to other user’s profile
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

                        if (post.userId == currentUserId) {
                          // Navigate to self profile screen (same as bottom nav one)
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        } else {
                          // Navigate to other user’s profile
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

              // Post image
              Image.network(post.imageUrl, width: double.infinity, fit: BoxFit.cover),

              // Caption
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  '${post.username}: ${post.caption}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // Like / Comment / Share row
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
                                scrollController: scrollController,
                              );
                            },
                          ),
                        );

                        // Refresh interaction state after commenting
                        final viewModel = Provider.of<PostInteractionViewModel>(context, listen: false);
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
                        await viewModel.init(); // Refresh comment count
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
