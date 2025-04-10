//views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import 'message_screen.dart';
import 'widgets/post_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Colors.black),
        title: const Text("The Shot"),
        backgroundColor: Colors.grey[100],
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.messenger_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessagesScreen()),
              );
            },
          ),

        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, homeViewModel, child) {
          if (homeViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (homeViewModel.posts.isEmpty) {
            return const Center(child: Text('No posts available.'));
          }

          return RefreshIndicator(
            onRefresh: () => homeViewModel.fetchPosts(),
            child: ListView.builder(
              itemCount: homeViewModel.posts.length,
              itemBuilder: (context, index) {
                final post = homeViewModel.posts[index];
                return PostCard(post: post);
              },
            ),
          );
        },
      ),
    );
  }
}
