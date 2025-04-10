// views/comment_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment_model.dart';
import '../viewmodels/comment_viewmodel.dart';

class CommentSection extends StatelessWidget {
  final String postId;

  const CommentSection({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommentViewModel(postId: postId),
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
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: comment.userProfilePic.isNotEmpty
                              ? NetworkImage(comment.userProfilePic)
                              : const AssetImage('assets/default_profile.png') as ImageProvider,
                        ),
                        title: Text(comment.username),
                        subtitle: Text(comment.text),
                        trailing: Text(
                          TimeOfDay.fromDateTime(comment.timestamp).format(context),
                          style: const TextStyle(fontSize: 12),
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

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Provider.of<CommentViewModel>(context, listen: false).addComment(text);
      _controller.clear();
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
