//views/create_video_post_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/categories.dart';
import '../viewmodels/create_post_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import 'package:video_player/video_player.dart';

class CreateVideoPostScreen extends StatefulWidget {
  final File videoFile;

  const CreateVideoPostScreen({Key? key, required this.videoFile}) : super(key: key);

  @override
  State<CreateVideoPostScreen> createState() => _CreateVideoPostScreenState();
}

class _CreateVideoPostScreenState extends State<CreateVideoPostScreen> {
  final _captionController = TextEditingController();
  String? _selectedCategory;
  String? _thumbnailPath;
  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }
  Future<void> _generateThumbnail() async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );
      if (mounted) {
        setState(() {
          _thumbnailPath = thumbnailPath;
        });
      }
    } catch (e) {
      print('Error generating thumbnail: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final List<String> _categories = SportCategories.list;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.videocam, size: 80),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(labelText: 'Caption'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
                final createPostViewModel = Provider.of<CreatePostViewModel>(context, listen: false);

                if (_selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a category')),
                  );
                  return;
                }

                await createPostViewModel.uploadVideoPost(
                  videoFile: widget.videoFile,
                  caption: _captionController.text,
                  category: _selectedCategory ?? 'Uncategorized',
                  context: context,
                  homeViewModel: homeViewModel,
                );

                Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
              },
              child: const Text('Upload Video'),
            ),
          ],
        ),
      ),
    );
  }
}
