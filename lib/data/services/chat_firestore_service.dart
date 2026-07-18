import 'package:cloud_firestore/cloud_firestore.dart';

class ChatFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getChatRooms(String buyerUid) {
    return _firestore
        .collection('chat_rooms')
        .where('buyerUid', isEqualTo: buyerUid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      list.sort((a, b) {
        final tA = a['lastMessageTime'] as Timestamp?;
        final tB = b['lastMessageTime'] as Timestamp?;
        if (tA == null && tB == null) return 0;
        if (tA == null) return 1;
        if (tB == null) return -1;
        return tB.compareTo(tA);
      });
      return list;
    });
  }

  Stream<List<Map<String, dynamic>>> getMessages(String roomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> sendMessage({
    required String roomId,
    required String buyerUid,
    required String buyerName,
    required int shopId,
    required String shopName,
    required String shopAvatarUrl,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    final timestamp = FieldValue.serverTimestamp();

    await _firestore.collection('chat_rooms').doc(roomId).set({
      'buyerUid': buyerUid,
      'buyerName': buyerName,
      'shopId': shopId,
      'shopName': shopName,
      'shopAvatarUrl': shopAvatarUrl,
      'lastMessage': content,
      'lastMessageSenderUid': senderId,
      'lastMessageTime': timestamp,
      'unreadCount': 0,
    }, SetOptions(merge: true));

    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp,
    });
  }

  Future<void> markRoomAsRead(String roomId) async {
      await _firestore.collection('chat_rooms').doc(roomId).update({
        'unreadCount': 0,
      });
  }
}
