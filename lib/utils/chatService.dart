import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/firebase/firebase_auth_service.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  //final _auth = FirebaseAuth.instance;

  // Send a message to a chat
  Future<void> sendMessage(String chatId, String messageText) async {
    try {
      final messagesCollection =
          _firestore.collection('Chats').doc(chatId).collection('Messages');

      await messagesCollection.add({
        'senderId': globalUID,
        'content': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update last message in the chat document
      await _firestore.collection('Chats').doc(chatId).update({
        'lastMessage': {
          'senderId': globalUID,
          'content': messageText,
          'timestamp': FieldValue.serverTimestamp(),
        }
      });
    } catch (e) {
      print('Error sending message: $e');
      // Handle the error appropriately (e.g., show a snackbar)
    }
  }

  // Get chat history for a given chat ID
  Stream<QuerySnapshot> getChatHistory(String chatId) {
    return _firestore
        .collection('Chats')
        .doc(chatId)
        .collection('Messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // Create a new chat (you'll need to adapt this based on how you
  // initiate chats between consumers and riders)
  Future<String> createChat(String consumerId, String riderId) async {
    try {
      final chatDocRef = await _firestore.collection('Chats').add({
        'participants': [consumerId, riderId],
        'lastMessage': null, // Initially no last message
      });

      return chatDocRef.id;
    } catch (e) {
      print('Error creating chat: $e');
      rethrow;
    }
  }

  // Get chats for a given user ID
  Stream<QuerySnapshot> getChatsForUser(String userId) {
    return _firestore
        .collection('Chats')
        .where('participants', arrayContains: userId)
        .snapshots();
  }
}
