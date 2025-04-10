// views/messages_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/message_list_viewmodel.dart';
import '../views/chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageListViewModel()..loadChats(),
      child: Consumer<MessageListViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Messages'),
              backgroundColor: Colors.grey[100],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: viewModel.searchUsers,
                  ),
                ),
                if (viewModel.isSearching)
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.searchedUsers.length,
                      itemBuilder: (context, index) {
                        final user = viewModel.searchedUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.profile_picture),
                          ),
                          title: Text(user.username),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  otherUserId: user.id,
                                  otherUsername: user.username,
                                  otherUserProfilePic: user.profile_picture,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.recentChats.length,
                      itemBuilder: (context, index) {
                        final chat = viewModel.recentChats[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(chat.receiverProfilePic),
                          ),
                          title: Text(chat.receiverUsername),
                          subtitle: Text(chat.lastMessage ?? ''),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  otherUserId: chat.receiverId,
                                  otherUsername: chat.receiverUsername,
                                  otherUserProfilePic: chat.receiverProfilePic,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
