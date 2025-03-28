
//views/post_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:the_shot2/views/camera_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_shot2/views/create_post_screen.dart';
import 'package:file_picker/file_picker.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Album> _albums = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndFetchAlbums();
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }


  Future<void> _requestPermissionsAndFetchAlbums() async {
    await requestPermissions();
    await _fetchAlbums();
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
      }

      var manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        manageStatus = await Permission.manageExternalStorage.request();
      }

      if (storageStatus.isGranted && manageStatus.isGranted) {
        print('Storage permissions granted');
      } else {
        print('Storage permissions denied');
        return;
      }
    } else {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }
    }
  }

  Future<void> _fetchAlbums() async {
    try {
      print('Fetching albums...');
      final albums = await PhotoGallery.listAlbums(
        mediumType: MediumType.image,
        newest: true,
        hideIfEmpty: true,
      );
      print('Albums fetched: ${albums.length}');
      setState(() {
        _albums = albums;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching albums: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  PlatformFile? _imageFile;

  List<File> _selectedFiles = [];

  Future<void> _pickImages() async {
    try {
      // Request storage permission
      var storageStatus = await Permission.storage.status;
      var manageStatus = await Permission.manageExternalStorage.status;

      if (storageStatus.isGranted && manageStatus.isGranted) {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );

        // ... (rest of the code remains the same)
      } else {
        print('Storage permission denied');
        // Handle permission denied scenario, e.g., show an error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Permission Denied'),
            content: Text('The app requires storage permission to access files.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post +'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _albums.isEmpty
          ? const Center(child: Text('No albums found'))
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          final album = _albums[index];
          return GestureDetector(
            onTap: () async {
              final mediaPage = await album.listMedia();
              if (mediaPage.items.isNotEmpty) {
                final firstMedium = mediaPage.items.first;
                // Handle medium selection
                // You can navigate to the create_post_screen.dart here
              }
            },
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: MemoryImage(kTransparentImage),
              image: AlbumThumbnailProvider(
                album: album,
                highQuality: true,
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickImages,
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
            },
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}



