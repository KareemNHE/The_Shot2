// views/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:the_shot2/views/edit_profile_screen.dart';
import 'package:the_shot2/views/login_screen.dart';
import 'package:the_shot2/viewmodels/profile_viewmodel.dart';
import 'package:the_shot2/views/post_detail_screen.dart';
import 'package:the_shot2/views/user_list_screen.dart';
import 'package:the_shot2/views/widgets/video_post_card.dart';
import 'package:the_shot2/views/widgets/post_card.dart';

import '../models/post_model.dart'; // For VideoPostDetailScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProfileViewModel>(context, listen: false).fetchUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _openSideMenu(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ProfileViewModel>(context, listen: false).fetchUserProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                backgroundImage: profileViewModel.profilePictureUrl.startsWith('http')
                    ? NetworkImage(profileViewModel.profilePictureUrl)
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              const SizedBox(height: 10),
              Text(
                profileViewModel.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  profileViewModel.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final snapshot = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('followers')
                          .get();

                      final ids = snapshot.docs.map((doc) => doc.id).toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserListScreen(
                            title: "Followers",
                            userIds: ids,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text('${profileViewModel.followersCount}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text('Followers'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () async {
                      final snapshot = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('following')
                          .get();

                      final ids = snapshot.docs.map((doc) => doc.id).toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserListScreen(
                            title: "Following",
                            userIds: ids,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text('${profileViewModel.followingCount}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text('Following'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildUserPostsGrid(profileViewModel.userPosts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserPostsGrid(List<PostModel> posts) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final post = posts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => post.type == 'video'
                      ? VideoPostDetailScreen(post: post)
                      : PostDetailScreen(post: post),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: post.type == 'video' && post.videoUrl.isNotEmpty
                  ? VideoPostCard(post: post, isThumbnailOnly: true)
                  : post.imageUrl.isNotEmpty
                  ? Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image),
              )
                  : const SizedBox(
                height: 200,
                child: Center(child: Icon(Icons.broken_image)),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openSideMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuItem(Icons.settings, 'Settings', () {}),
              _buildMenuItem(Icons.edit, 'Edit Profile', () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
                if (result == true) {
                  await Provider.of<ProfileViewModel>(context, listen: false)
                      .fetchUserProfile();
                  setState(() {});
                }
              }),
              _buildMenuItem(Icons.help, 'Help', () {}),
              _buildMenuItem(Icons.logout, 'Logout', () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Login()),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
