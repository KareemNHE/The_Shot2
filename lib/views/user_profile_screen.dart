//views/user_profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shot2/views/post_detail_screen.dart';
import 'package:the_shot2/views/user_list_screen.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import '../models/search_model.dart';
import '../models/post_model.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProfileViewModel()..fetchUserProfile(userId),
      child: Consumer<UserProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = viewModel.user;
          final posts = viewModel.posts;

          return Scaffold(
            appBar: AppBar(
              title: Text(user?.username ?? 'User'),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await viewModel.fetchUserProfile(userId);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // ensures drag is always possible
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user!.profile_picture),
                    ),
                    const SizedBox(height: 10),
                    Text(user.username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(user.first_name + user.last_name),
                    Text(user.bio, style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final snapshot = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.id)
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
                              Text('${viewModel.followersCount}', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Followers'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 30),
                        GestureDetector(
                          onTap: () async {
                            final snapshot = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.id)
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
                              Text('${viewModel.followingCount}', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Following'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await viewModel.toggleFollow(user.id);
                        final msg = viewModel.isFollowing
                            ? 'You are now following @${user.username}'
                            : 'You unfollowed @${user.username}';

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        await viewModel.fetchUserProfile(userId); // Also refresh immediately on follow
                      },
                      child: Text(viewModel.isFollowing ? "Unfollow" : "Follow"),
                    ),
                    const Divider(height: 30),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10.0),
                      itemCount: posts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                post.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}