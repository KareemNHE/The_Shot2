//views/post_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:provider/provider.dart';
import 'package:the_shot2/views/camera_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_shot2/views/create_post_screen.dart';
import 'package:file_picker/file_picker.dart';

import '../viewmodels/profile_viewmodel.dart';

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
      if (await Permission.photos.isGranted) {
        print("Photos permission already granted");
        return;
      }

      final status = await Permission.photos.request();

      if (status.isGranted) {
        print("Photos permission granted");
      } else {
        print("Photos permission denied");
      }
    } else if (Platform.isIOS) {
      final status = await Permission.mediaLibrary.request();
      if (status.isGranted) {
        print("IOS media permission granted");
      } else {
        print("iOS media permission denied");
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
      final permission = await Permission.photos.request();

      if (!permission.isGranted) {
        print('Photos permission denied');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied. Cannot access gallery.')),
        );
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null && result.files.isNotEmpty) {
        print("Picked ${result.files.length} files");
      } else {
        print('No files selected');
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
                          final file = await firstMedium.getFile();

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreatePostScreen(imageUrl: file.path),
                            ),
                          );

                          if (result == true) {
                            await Provider.of<ProfileViewModel>(context,
                                    listen: false)
                                .fetchUserProfile();
                            setState(() {}); // Refresh the profile UI
                            Navigator.pop(
                                context); // Pop back to home after post
                          }
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
            heroTag: 'pick_photo',
            onPressed: _pickImages,
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'open_camera',
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
