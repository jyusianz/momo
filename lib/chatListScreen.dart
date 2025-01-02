import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/firebase/firebase_auth_service.dart';
import 'package:food/utils/chatService.dart';
import 'package:food/chatCard.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String searchQuery = '';
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '\n',
              ),
              TextSpan(
                text: '\t\tMessages',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.start,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for message',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'Momo_images/Vector.png', // Replace with your actual image path
                    height: 30,
                    width: 30,
                  ),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 240, 240, 240),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatService.getChatsForUser(globalUID!),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading chats'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredChats = snapshot.data!.docs.where((chatDoc) {
                    final chatData = chatDoc.data() as Map<String, dynamic>;

                    // Get participant IDs
                    final participants = chatData['participants'] as List;

                    // Get the ID of the other participant
                    final otherParticipantId =
                        participants.firstWhere((id) => id != globalUID);
                    final chatName = chatData['name'] ?? '';
                    return chatName
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filteredChats.isEmpty) {
                    return Center(
                      // Display this when there are no chats
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'Momo_images/nochat.png', // Replace with your image path
                            height: 200,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No conversations yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chatDoc = filteredChats[index];
                        final chatData = chatDoc.data() as Map<String, dynamic>;
                        return FutureBuilder<DocumentSnapshot>(
                          future: _getOtherParticipantName(
                              chatData['participants'] as List),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Error loading name'));
                            }

                            final name = snapshot.data!.get('First Name') +
                                    ' ' +
                                    snapshot.data!.get('Last Name') ??
                                'Unknown';

                            return GestureDetector(
                              onTap: () {
                                final chatId = chatDoc.id;
                                print(
                                    'Chat ID: $chatId'); // Check if chatId is null
                                Navigator.pushNamed(context, '/chatScreen',
                                    arguments: chatId);
                              },
                              child: ChatCard(
                                avatar:
                                    'assets/images/avatar.png', // Replace with your default avatar path
                                name: name,
                                message:
                                    chatData['lastMessage']?['content'] ?? '',
                                time: (chatData['lastMessage']?['timestamp']
                                            as Timestamp?)
                                        ?.toDate()
                                        .toString() ??
                                    '',
                                notification: chatData['notification'] ?? 0,
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              _navigateToHome();
            },
            child: Image.asset(
                'Momo_images/home.png'), // Replace with your actual image path
          ),
          InkWell(
            onTap: () {
              _navigateToList();
            },
            child: Image.asset(
                'Momo_images/orders.png'), // Replace with your actual image path
          ),
          InkWell(
            onTap: () {
              //do nothing
            },
            child: Image.asset(
                'Momo_images/chat.png'), // Replace with your actual image path
          ),
          InkWell(
            onTap: () {
              _navigateToProfile();
            },
            child: Image.asset(
                'Momo_images/profile.png'), // Replace with your actual image path
          ),
        ],
      ),
    );
  }

  // Helper function to get the other participant's name
  Future<DocumentSnapshot> _getOtherParticipantName(List participants) async {
    final otherParticipantId = participants.firstWhere((id) => id != globalUID);

    // Fetch the name from the appropriate collection ('consumers' or 'riders')
    DocumentSnapshot userDoc;
    if (await _isConsumer(otherParticipantId)) {
      userDoc = await FirebaseFirestore.instance
          .collection('Consumer')
          .doc(otherParticipantId)
          .get();
    } else {
      userDoc = await FirebaseFirestore.instance
          .collection('Rider')
          .doc(otherParticipantId)
          .get();
    }

    return userDoc; // Return the document
  }

  Future<bool> _isConsumer(String userId) async {
    try {
      DocumentSnapshot consumerDoc = await FirebaseFirestore.instance
          .collection('Consumer')
          .doc(userId)
          .get();
      return consumerDoc.exists; // Returns true if the user is a consumer
    } catch (e) {
      print('Error checking user type: $e');
      return false; // Or handle the error appropriately
    }
  }

  // Navigation functions
  void _navigateToHome() async {
    String userType = await _getUserType();
    if (userType == 'Consumer') {
      Navigator.pushNamed(context, '/consumerHome');
    } else if (userType == 'Rider') {
      Navigator.pushNamed(context, '/riderHome');
    }
  }

  void _navigateToList() async {
    String userType = await _getUserType();
    if (userType == 'Consumer') {
      Navigator.pushNamed(context, '/listconsumer');
    } else if (userType == 'Rider') {
      Navigator.pushNamed(context, '/listrider');
    }
  }

  void _navigateToProfile() async {
    String userType = await _getUserType();
    if (userType == 'Consumer') {
      Navigator.pushNamed(context, '/consumerprofile');
    } else if (userType == 'Rider') {
      Navigator.pushNamed(context, '/riderprofile');
    }
  }

  // Helper function to get user type from Firestore
  Future<String> _getUserType() async {
    String userT = '';
    try {
      // Check in 'consumers' collection first
      DocumentSnapshot consumerDoc = await FirebaseFirestore.instance
          .collection('Consumer')
          .doc(globalUID)
          .get();

      if (consumerDoc.exists) {
        userT = 'consumer';
        return 'Consumer';
      } else {
        // If not found in 'consumers', check 'riders' collection
        DocumentSnapshot riderDoc = await FirebaseFirestore.instance
            .collection('Rider')
            .doc(globalUID)
            .get();
        if (riderDoc.exists) {
          userT = 'rider';
          return 'Rider';
        }
      }
      print(userT);
      return 'unknown'; // Or handle the case where globalUid is empty or user not found
    } catch (e) {
      print('Error getting user type: $e');
      return 'unknown';
    }
  }
}
