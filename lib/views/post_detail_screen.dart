// views/post_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shot2/views/post_share_screen.dart';
import 'package:the_shot2/views/user_profile_screen.dart';
import 'package:the_shot2/views/widgets/custom_video_player.dart';
import '../models/post_model.dart';
import '../viewmodels/post_interaction_viewmodel.dart';
import 'comment_section_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel? post;
  final String? postId;
  final String? postOwnerId;

  const PostDetailScreen({Key? key, this.post, this.postId, this.postOwnerId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _post = widget.post!;
      _isLoading = false;
    } else {
      _fetchPost();
    }
  }

  Future<void> _fetchPost() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.postOwnerId)
          .collection('posts')
          .doc(widget.postId)
          .get();

      final data = doc.data();
      if (data != null) {
        PostModel post = PostModel.fromFirestore(data, doc.id);

        // Fetch username/profilePic if missing
        if (post.username == 'Unknown' || post.userProfilePic.isEmpty) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(post.userId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            post = PostModel(
              id: post.id,
              userId: post.userId,
              username: userData?['username'] ?? 'Unknown',
              userProfilePic: userData?['profile_picture'] ?? '',
              imageUrl: post.imageUrl,
              videoUrl: post.videoUrl.isNotEmpty ? post.videoUrl : '',
              thumbnailUrl: post.thumbnailUrl,
              caption: post.caption,
              timestamp: post.timestamp,
              hashtags: post.hashtags,
              category: post.category,
              type: post.type.isNotEmpty ? post.type : 'image',
            );
          }
        }

        setState(() {
          _post = post;
          _isLoading = false;
        });
      } else {
        _showPostNotFound();
      }
    } catch (e) {
      _showPostNotFound();
    }
  }



  void _showPostNotFound() {
    setState(() {
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Post not found"),
          content: const Text("This post may have been deleted or doesn't exist."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Post")),
        body: const Center(child: Text("Post not found or deleted.")),
      );
    }

    final post = _post!;

    return ChangeNotifierProvider(
      create: (_) => PostInteractionViewModel(
        postId: post.id,
        postOwnerId: post.userId,
      )..init(),
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
                post.videoUrl.isNotEmpty
                    ? CustomVideoPlayer(videoUrl: post.videoUrl)
                    : post.imageUrl.isNotEmpty
                    ? Image.network(post.imageUrl, width: double.infinity, fit: BoxFit.cover)
                    : const SizedBox(height: 200, child: Center(child: Icon(Icons.broken_image))),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(post.caption),
                ),
                Row(
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
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.7,
                            child: CommentSection(
                              postId: post.id,
                              postOwnerId: post.userId,
                            ),
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
              ],
            );
          },
        ),
      ),
    );
  }
}
