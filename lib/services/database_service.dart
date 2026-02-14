import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Use a nullable check for the UID to prevent crashes during logout transitions
  String get currentUid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No user logged in");
    return user.uid;
  }

  // 1. Start a Chat by searching Email
  Future<void> startNewChat(String email, String groupName) async {
    // Search for user with matching email (case-insensitive)
    var query = await _db
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .get();

    if (query.docs.isEmpty) throw Exception("User not found!");

    var targetUser = query.docs.first;
    String targetUid = targetUser['uid'];

    if (targetUid == currentUid) {
      throw Exception("You can't chat with yourself!");
    }

    // Check if a chat between these two already exists to avoid duplicates
    var existing = await _db
        .collection('groups')
        .where('members', arrayContains: currentUid)
        .get();

    bool alreadyExists = existing.docs.any(
      (doc) => (doc['members'] as List).contains(targetUid),
    );

    if (alreadyExists) {
      // If it exists, just clear 'hiddenBy' so it reappears for the user
      var chatDoc = existing.docs.firstWhere(
        (doc) => (doc['members'] as List).contains(targetUid),
      );
      await chatDoc.reference.update({'hiddenBy': []});
      return;
    }

    // Create new group document
    await _db.collection('groups').add({
      'name': groupName.trim(),
      'members': [currentUid, targetUid],
      'hiddenBy': [], // Tracks users who "deleted" the chat locally
      'lastMessage': 'No messages yet...',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Send Message and Update Group Preview
  Future<void> sendMessage(String groupId, String text) async {
    if (text.trim().isEmpty) return;

    WriteBatch batch = _db.batch();

    // Reference for the new message in the sub-collection
    DocumentReference msgRef = _db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc();

    // Reference for the parent group document
    DocumentReference groupRef = _db.collection('groups').doc(groupId);

    batch.set(msgRef, {
      'text': text.trim(),
      'senderId': currentUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(groupRef, {
      'lastMessage': text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      'hiddenBy':
          [], // Crucial: Re-shows the chat for both users if it was hidden
    });

    await batch.commit();
  }

  // 3. Local Delete: Hide chat for current user only
  Future<void> hideChat(String groupId) async {
    await _db.collection('groups').doc(groupId).update({
      'hiddenBy': FieldValue.arrayUnion([currentUid]),
    });
  }

  // 4. Fetch the email of the other person (recipient)
  Future<String> getRecipientEmail(List<dynamic> members) async {
    try {
      // Identify the UID that isn't the current user
      String otherUid = members.firstWhere(
        (id) => id != currentUid,
        orElse: () => '',
      );

      if (otherUid.isEmpty) return 'Note to Self';

      var userDoc = await _db.collection('users').doc(otherUid).get();
      if (!userDoc.exists) return 'Unknown User';

      return userDoc.data()?['email'] ?? 'No email found';
    } catch (e) {
      return 'Error loading email';
    }
  }
}
