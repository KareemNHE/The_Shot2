// views/post_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shot2/views/user_profile_screen.dart';
import '../models/post_models.dart';
import '../viewmodels/post_interaction_viewmodel.dart';
import 'comment_section_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostInteractionViewModel(postId: post.id)..init(),
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              if (post.userId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserProfileScreen(userId: post.userId)),
                );
              }
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: post.userProfilePic.isNotEmpty
                      ? NetworkImage(post.userProfilePic)
                      : const AssetImage('assets/default_profile.png') as ImageProvider,
                ),
                const SizedBox(width: 8),
                Text(post.username.isNotEmpty ? post.username : 'Unknown'),
              ],
            ),
          ),
        ),

        body: Consumer<PostInteractionViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(post.imageUrl, width: double.infinity, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(post.caption),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(viewModel.isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.red),
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
                            builder: (context) => FractionallySizedBox(
                              heightFactor: 0.7,
                              child: CommentSection(postId: post.id),
                            ),
                          );
                          await viewModel.init();
                        }

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
                                return CommentSectionSheet(
                                  postId: post.id,
                                  scrollController: scrollController,
                                );
                              },
                            ),
                          );

                          await viewModel.init(); // Refresh comment count
                        }

                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
