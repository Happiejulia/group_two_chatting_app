import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Use a getter for UID to avoid errors if the user logs out
  String get currentUid => FirebaseAuth.instance.currentUser!.uid;

  // 1. Start a Chat by searching Email
  Future<void> startNewChat(String email, String groupName) async {
    var query = await _db
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .get();

    if (query.docs.isEmpty) throw Exception("User not found!");

    var targetUser = query.docs.first;

    // Prevent starting a chat with yourself
    if (targetUser['uid'] == currentUid)
      throw Exception("You can't chat with yourself!");

    await _db.collection('groups').add({
      'name': groupName,
      'members': [currentUid, targetUser['uid']],
      'lastMessage': 'No messages yet...',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Send Message and Update Group Preview
  Future<void> sendMessage(String groupId, String text) async {
    if (text.trim().isEmpty) return;

    WriteBatch batch = _db.batch();

    // Reference for the new message
    DocumentReference msgRef = _db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc();

    // Reference for the group to update lastMessage
    DocumentReference groupRef = _db.collection('groups').doc(groupId);

    batch.set(msgRef, {
      'text': text.trim(),
      'senderId': currentUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(groupRef, {
      'lastMessage': text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
