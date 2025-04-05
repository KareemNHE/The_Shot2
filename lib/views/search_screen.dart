//views/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';

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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search users, hashtags, categories...',
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

          return SingleChildScrollView(
            child: Column(
              children: [
                if (users.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.profile_picture.startsWith('http')
                              ? NetworkImage(user.profile_picture)
                              : AssetImage(user.profile_picture) as ImageProvider,
                        ),
                        title: Text(user.username),
                        subtitle: Text(user.first_name + user.last_name),
                        onTap: () {
                          // TODO: Navigate to profile
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
                      child: Image.network(
                        post.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                      ),
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
