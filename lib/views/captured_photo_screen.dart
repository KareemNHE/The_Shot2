// views/captured_photo_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/captured_photo_viewmodel.dart';
import 'camera_screen.dart';
import 'create_post_screen.dart';

class CapturedPhotoScreen extends StatelessWidget {
  final String imagePath;

  const CapturedPhotoScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final capturedPhotoViewModel = Provider.of<CapturedPhotoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Photo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file(File(imagePath)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => capturedPhotoViewModel.savePhoto(imagePath),
            child: const Text('Save Photo'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final downloadUrl = await capturedPhotoViewModel.uploadPhoto(imagePath, context);
              if (downloadUrl != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePostScreen(imageUrl: downloadUrl),
                  ),
                );
              }
            },
            child: const Text('Post Photo'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
            },
            child: const Text('Retake Photo'),
          ),
        ],
      ),
    );
  }
}
