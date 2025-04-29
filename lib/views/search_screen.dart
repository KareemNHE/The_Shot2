//views/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shot2/views/post_detail_screen.dart';
import 'package:the_shot2/views/user_profile_screen.dart';
import 'package:the_shot2/views/widgets/post_card.dart';
import 'package:the_shot2/views/widgets/video_post_card.dart';
import '../viewmodels/home_viewmodel.dart';
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
    Future.microtask(() => Provider.of<SearchViewModel>(context, listen: false)
        .fetchAllUserPosts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                Provider.of<SearchViewModel>(context, listen: false).search(query);
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<SearchViewModel>(context, listen: false)
              .fetchAllUserPosts(isRefresh: true);
        },
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        displacement: 40.0,
        child: Consumer<SearchViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && !viewModel.isRefreshing) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage!),
                    action: SnackBarAction(
                      label: 'Retry',
                      onPressed: () {
                        viewModel.clearError();
                        viewModel.fetchAllUserPosts(isRefresh: true);
                      },
                    ),
                  ),
                );
              });
            }

            final users = viewModel.filteredUsers;
            final posts = viewModel.allPosts;
            final query = _searchController.text.trim();

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (query.isNotEmpty && users.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.profile_picture.isNotEmpty
                                ? (user.profile_picture.startsWith('http')
                                ? NetworkImage(user.profile_picture)
                                : AssetImage(user.profile_picture)
                            as ImageProvider)
                                : const AssetImage('assets/default_profile.png'),
                          ),
                          title: Text(user.username),
                          subtitle: Text('${user.first_name} ${user.last_name}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UserProfileScreen(userId: user.id),
                              ),
                            ).then((_) {
                              Provider.of<HomeViewModel>(context, listen: false)
                                  .fetchPosts();
                            });
                          },
                        );
                      },
                      childCount: users.length,
                    ),
                  ),
                if (query.isNotEmpty && users.isNotEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final post = posts[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GestureDetector(
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
                          child: post.type == 'video'
                              ? VideoPostCard(
                              post: post, isThumbnailOnly: true)
                              : Image.network(
                            post.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                          ),
                        ),
                      );
                    },
                    childCount: posts.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: posts.isEmpty && users.isEmpty && !viewModel.isLoading
                      ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No results found')),
                  )
                      : const SizedBox(height: 10),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}