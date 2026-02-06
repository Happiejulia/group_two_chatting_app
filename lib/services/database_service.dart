import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> startNewChat(String email, String groupName) async {
    var query = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isEmpty) throw Exception("User not found!");

    var targetUser = query.docs.first;
    await _db.collection('groups').add({
      'name': groupName,
      'members': [currentUid, targetUser['uid']],
      'lastMessage': 'New chat created',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
