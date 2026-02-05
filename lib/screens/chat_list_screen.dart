import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import 'chat_room_screen.dart';
import 'settings_screen.dart';

class ChatListScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ChatListScreen({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (c) => SettingsScreen(isDarkMode: isDarkMode, onThemeChanged: onThemeChanged))),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('groups')
            .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No chats. Tap + to start!"));

          return ListView(
            children: snapshot.data!.docs.map((doc) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(doc['name']),
              subtitle: Text(doc['lastMessage']),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ChatRoomScreen(groupId: doc.id))),
            )).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddChat(context),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  void _showAddChat(context) {
    final email = TextEditingController();
    final name = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Start Chat"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(hintText: "Chat Name")),
        TextField(controller: email, decoration: const InputDecoration(hintText: "Friend's Email")),
      ]),
      actions: [ElevatedButton(onPressed: () {
        DatabaseService().startNewChat(email.text, name.text);
        Navigator.pop(c);
      }, child: const Text("Create"))],
    ));
  }
}