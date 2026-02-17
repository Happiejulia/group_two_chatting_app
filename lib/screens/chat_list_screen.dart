import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import 'chat_room_screen.dart';
import 'settings_screen.dart';

class ChatListScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ChatListScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Recent Chats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => SettingsScreen(
                  isDarkMode: isDarkMode,
                  onThemeChanged: onThemeChanged,
                ),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('members',
                arrayContains: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chat_bubble_outline,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No recent chats",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  Text("Tap + to start a conversation"),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(vertical: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];

              String name = doc['name'] ?? "Chat";
              String lastMessage =
                  doc['lastMessage'] ?? "No messages yet";

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          Theme.of(context)
                              .colorScheme
                              .primary,
                      child: Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                          color:
                              Colors.grey[600]),
                    ),
                    trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) =>
                            ChatRoomScreen(
                                groupId:
                                    doc.id),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () => _showAddChat(context),
        child:
            const Icon(Icons.add_comment),
      ),
    );
  }

  void _showAddChat(context) {
    final email =
        TextEditingController();
    final name =
        TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title:
            const Text("Start Chat"),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration:
                  const InputDecoration(
                      hintText:
                          "Chat Name"),
            ),
            const SizedBox(
                height: 10),
            TextField(
              controller: email,
              decoration:
                  const InputDecoration(
                      hintText:
                          "Friend's Email"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              DatabaseService()
                  .startNewChat(
                      email.text,
                      name.text);
              Navigator.pop(c);
            },
            child:
                const Text("Create"),
          )
        ],
      ),
    );
  }
}
