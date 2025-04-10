//views/widgets/post_card.dart

import 'package:flutter/material.dart';
import '../../models/post_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/post_interaction_viewmodel.dart';


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
              // Post image
              Image.network(post.imageUrl, width: double.infinity, fit: BoxFit.cover),

              // Username and caption
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  '${post.username}: ${post.caption}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // Action Row: Like | Comment | Share
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate to user profile using post.userId if available
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: post.userProfilePic.isNotEmpty
                            ? NetworkImage(post.userProfilePic)
                            : const AssetImage('assets/default_profile.png') as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        // Navigate to user profile
                      },
                      child: Text(
                        post.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
