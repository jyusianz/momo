import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Momo/firebase/firebase_auth_service.dart';
import 'package:Momo/utils/chatService.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final String chatId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getOtherParticipantName(chatId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (snapshot.hasError) {
              return const Text('Error');
            }
            return Text(snapshot.data ?? 'Unknown');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getChatHistory(chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading messages'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final messageText = messageData['content'];
                    final isSent = messageData['senderId'] == globalUID;

                    return Align(
                      alignment:
                          isSent ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 300),
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSent ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Text(
                          messageText,
                          style: TextStyle(
                            color: isSent ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(chatId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getOtherParticipantName(String chatId) async {
    try {
      print(chatId);
      DocumentSnapshot chatDoc = await FirebaseFirestore.instance
          .collection('Chats')
          .doc(chatId)
          .get();
      print(chatDoc);
      List participants = chatDoc['participants'] as List;
      print(participants);

      // Assuming the current user is always one of the participants
      String otherParticipantId =
          participants.firstWhere((participant) => participant != globalUID);

      DocumentSnapshot participantDoc;
      // Assuming you have separate collections for consumers and riders
      if (await _isConsumer(otherParticipantId)) {
        participantDoc = await FirebaseFirestore.instance
            .collection('Consumer')
            .doc(otherParticipantId)
            .get();
      } else {
        participantDoc = await FirebaseFirestore.instance
            .collection('Rider')
            .doc(otherParticipantId)
            .get();
      }
      return participantDoc.get('First Name') +
              ' ' +
              participantDoc.get('Last Name') ??
          'Unknown';
    } catch (e) {
      print('Error getting other participant name: $e');
      return 'Unknown';
    }
  }

  Future<bool> _isConsumer(String userId) async {
    try {
      DocumentSnapshot consumerDoc = await FirebaseFirestore.instance
          .collection('Consumer')
          .doc(userId)
          .get();
      return consumerDoc.exists;
    } catch (e) {
      print('Error checking if user is consumer: $e');
      return false;
    }
  }

  void _sendMessage(String chatId) {
    String text = _textController.text.trim();
    if (text.isNotEmpty) {
      _chatService.sendMessage(chatId, text);
      _textController.clear();
    }
  }
}
