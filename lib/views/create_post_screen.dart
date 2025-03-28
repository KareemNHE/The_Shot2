// views/create_post_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/create_post_viewmodel.dart';
import 'home_screen.dart';
import '../viewmodels/home_viewmodel.dart';

class CreatePostScreen extends StatefulWidget {
  final String imageUrl;

  const CreatePostScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final createPostViewModel = Provider.of<CreatePostViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Column(
        children: [
          Image.network(widget.imageUrl),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              hintText: 'Enter caption',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

              await createPostViewModel.createPost(
                imageUrl: widget.imageUrl,
                caption: _captionController.text,
                context: context,
                homeViewModel: homeViewModel,
              );

              // Navigate to the home screen after post creation
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
