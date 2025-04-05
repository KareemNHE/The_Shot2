// views/create_post_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/create_post_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'bnb.dart';
import 'home_screen.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/categories.dart';

class CreatePostScreen extends StatefulWidget {
  final String imageUrl;

  const CreatePostScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();

  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final createPostViewModel = Provider.of<CreatePostViewModel>(context);
    final List<String> _categories = SportCategories.list;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Column(
        children: [
          widget.imageUrl.startsWith('http')
              ? Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Center(child: Text('Failed to load image')),
          )
              : Image.file(
            File(widget.imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Center(child: Text('Failed to load image')),
          ),
          SizedBox(height:20),

          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              hintText: 'Enter caption',
            ),
          ),
          SizedBox(height:20),

          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Select Sport Category',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final homeViewModel =
                  Provider.of<HomeViewModel>(context, listen: false);

              if (_selectedCategory == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a category')),
                );
                return;
              }

              await createPostViewModel.createPost(
                imageUrl: widget.imageUrl,
                caption: _captionController.text,
                category: _selectedCategory!,
                context: context,
                homeViewModel: homeViewModel,
              );
              // Navigate to home screen after successful post
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottomNavBar()),
                (route) => false,
              );

              final profileViewModel =
                  Provider.of<ProfileViewModel>(context, listen: false);
              await profileViewModel.fetchUserProfile();
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
