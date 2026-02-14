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
    String myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
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
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('members', arrayContains: myUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chats yet. Tap + to start!"));
          }

          // FIX: Safely check for 'hiddenBy' field to avoid "Bad State" error
          final docs = snapshot.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            // If the field doesn't exist (old documents), treat as empty list
            List hiddenBy = data.containsKey('hiddenBy')
                ? data['hiddenBy']
                : [];
            return !hiddenBy.contains(myUid);
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("No active chats."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text("Delete Chat?"),
                      content: const Text(
                        "This will remove the chat from your list for you.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) => DatabaseService().hideChat(doc.id),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(data['name'] ?? 'Unnamed Group'),
                  subtitle: Text(
                    data['lastMessage'] ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => ChatRoomScreen(
                        groupId: doc.id,
                        members: data['members'],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddChat(context),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  void _showAddChat(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Start New Chat"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Chat Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: "Friend's Email"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (emailController.text.isEmpty ||
                    nameController.text.isEmpty) {
                  throw "Please fill in all fields";
                }
                await DatabaseService().startNewChat(
                  emailController.text,
                  nameController.text,
                );
                Navigator.pop(c);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
