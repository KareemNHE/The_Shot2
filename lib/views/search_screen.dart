//views/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shot2/views/post_detail_screen.dart';
import 'package:the_shot2/views/user_profile_screen.dart';
import 'package:the_shot2/viewmodels/user_profile_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';
import 'bnb.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SearchViewModel>(context, listen: false).fetchAllUserPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(35.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (query) {
                Provider.of<SearchViewModel>(context, listen: false)
                    .search(query);
              },
            ),
          ),
        ),
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = viewModel.filteredUsers;
          final posts = viewModel.allPosts;
          final query = _searchController.text.trim();

          return SingleChildScrollView(
            child: Column(
              children: [
                if (query.isNotEmpty && users.isNotEmpty)
                  ListView.builder(
                  shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.profile_picture.isNotEmpty
                              ? (user.profile_picture.startsWith('http')
                              ? NetworkImage(user.profile_picture)
                              : AssetImage(user.profile_picture) as ImageProvider)
                              : const AssetImage('assets/default_profile.png'),
                        ),
                        title: Text(user.username),
                        subtitle: Text(user.first_name + user.last_name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfileScreen(userId: user.id),
                            ),
                          ).then((_) {
                            Provider.of<HomeViewModel>(context, listen: false).fetchPosts();
                          });
                        },
                      );
                    },
                  ),
                const SizedBox(height: 10),
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
                      )
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
