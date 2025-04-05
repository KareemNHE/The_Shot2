// views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:the_shot2/views/edit_profile_screen.dart';
import 'package:the_shot2/views/login_screen.dart';
import 'package:the_shot2/viewmodels/profile_viewmodel.dart';
import 'package:the_shot2/viewmodels/edit_profile_viewmodel.dart';
import 'package:the_shot2/views/edit_profile_screen.dart';


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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Profile'),
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
              // Profile Picture
              CircleAvatar(
                radius: 60,
                backgroundImage: profileViewModel.profilePictureUrl.startsWith('http')
                    ? NetworkImage(profileViewModel.profilePictureUrl)
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              const SizedBox(height: 10),
              // Username
              Text(
                profileViewModel.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Bio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  profileViewModel.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 20),
              // Follower & Following Count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatColumn('Followers', profileViewModel.followersCount),
                  const SizedBox(width: 20),
                  _buildStatColumn('Following', profileViewModel.followingCount),
                ],
              ),
              const SizedBox(height: 20),
              // User Posts Grid
              _buildUserPostsGrid(profileViewModel.userPosts),
            ],
          ),
        ),
      ),
    );
  }

  // Stats Widget
  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // User Posts Grid
  Widget _buildUserPostsGrid(List<String> posts) {
    print("Rendering user post grid with ${posts.length} posts"); // <-- Add this

    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Text(
          'No posts yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

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
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              posts[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
          );
        },
      ),
    );
  }

  // Side Menu Drawer
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
                // Refetch the profile after editing
                if (result == true) {
                  await Provider.of<ProfileViewModel>(context, listen: false)
                      .fetchUserProfile();
                  setState(() {}); // Force re-render
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

  // Menu Item Builder
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
