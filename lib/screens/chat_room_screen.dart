import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomScreen extends StatelessWidget {
  final String groupId;
  final _msg = TextEditingController();

  ChatRoomScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('groups').doc(groupId)
                  .collection('messages').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    bool isMe = doc['senderId'] == FirebaseAuth.instance.currentUser!.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(color: isMe ? Colors.blue : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                        child: Text(doc['text'], style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(child: TextField(controller: _msg)),
              IconButton(icon: const Icon(Icons.send), onPressed: () {
                FirebaseFirestore.instance.collection('groups').doc(groupId).collection('messages').add({
                  'text': _msg.text,
                  'senderId': FirebaseAuth.instance.currentUser!.uid,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                _msg.clear();
              })
            ]),
          )
        ],
      ),
    );
  }
}