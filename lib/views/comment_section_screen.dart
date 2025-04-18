// views/comment_section_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment_model.dart';
import '../viewmodels/comment_interaction_viewmodel.dart';
import '../viewmodels/comment_viewmodel.dart';

class CommentSection extends StatelessWidget {
  final String postId;
  final String postOwnerId;

  const CommentSection({Key? key, required this.postId, required this.postOwnerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommentViewModel(postId: postId, postOwnerId: postOwnerId),

      child: Scaffold(
        appBar: AppBar(title: const Text('Comments')),
        body: Column(
          children: [
            Expanded(
              child: Consumer<CommentViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.comments.isEmpty) {
                    return const Center(child: Text('No comments yet.'));
                  }

                  return ListView.builder(
                    itemCount: viewModel.comments.length,
                    itemBuilder: (context, index) {
                      final comment = viewModel.comments[index];
                      return ChangeNotifierProvider(
                        create: (_) => CommentInteractionViewModel(
                          postId: postId,
                          commentId: comment.id,
                        ),
                        child: Consumer<CommentInteractionViewModel>(
                          builder: (context, commentViewModel, _) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    comment.userProfilePic.isNotEmpty
                                        ? NetworkImage(comment.userProfilePic)
                                        : const AssetImage(
                                                'assets/default_profile.png')
                                            as ImageProvider,
                              ),
                              title: Text(comment.username),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment.text),
                                  Row(
                                    children: [
                                      Text(
                                        TimeOfDay.fromDateTime(
                                                comment.timestamp)
                                            .format(context),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () =>
                                            commentViewModel.toggleLike(),
                                        child: Icon(
                                          commentViewModel.isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('${commentViewModel.likeCount}',
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            _CommentInputField(postId: postId),
          ],
        ),
      ),
    );
  }
}

class _CommentInputField extends StatefulWidget {
  final String postId;

  const _CommentInputField({required this.postId});

  @override
  State<_CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<_CommentInputField> {
  final TextEditingController _controller = TextEditingController();

  void _submitComment() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      await Provider.of<CommentViewModel>(context, listen: false)
          .addComment(text);
      Navigator.pop(context); // Dismiss the bottom sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitComment,
            ),
          ],
        ),
      ),
    );
  }
}


class CommentSectionSheet extends StatelessWidget {
  final String postId;
  final String postOwnerId;
  final ScrollController scrollController;

  const CommentSectionSheet({
    required this.postId,
    required this.postOwnerId,
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommentViewModel(postId: postId, postOwnerId: ''),
      child: Consumer<CommentViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  controller: scrollController,
                  itemCount: viewModel.comments.length,
                  itemBuilder: (context, index) {
                    final comment = viewModel.comments[index];
                    return ChangeNotifierProvider(
                      create: (_) => CommentInteractionViewModel(
                        postId: postId,
                        commentId: comment.id,
                      ),
                      child: Consumer<CommentInteractionViewModel>(
                        builder: (context, commentViewModel, _) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: comment.userProfilePic.isNotEmpty
                                  ? NetworkImage(comment.userProfilePic)
                                  : const AssetImage('assets/default_profile.png') as ImageProvider,
                            ),
                            title: Text(comment.username),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.text),
                                Row(
                                  children: [
                                    Text(
                                      TimeOfDay.fromDateTime(comment.timestamp).format(context),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => commentViewModel.toggleLike(),
                                      child: Icon(
                                        commentViewModel.isLiked ? Icons.favorite : Icons.favorite_border,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${commentViewModel.likeCount}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              _CommentInputField(postId: postId),
            ],
          );
        },
      ),
    );
  }
}
