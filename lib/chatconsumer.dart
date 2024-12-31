import 'package:flutter/material.dart';

class Chatconsumer extends StatefulWidget {
  const Chatconsumer({super.key});

  @override
  State<Chatconsumer> createState() => _ChatconsumerState();
}

// I love jeushian
class _ChatconsumerState extends State<Chatconsumer> {
  final List<Map<String, dynamic>> chats = [
    {
      'avatar': 'Momo_images/Juan Deck.png',
      'name': 'Rider1',
      'message': 'Maam asa ka?',
      'time': 'Today',
      'notification': 1
    },
    {
      'avatar': 'Momo_images/Juliet.png',
      'name': 'Rider 2R',
      'message': 'Naako sa gawas maam',
      'time': '17/6',
      'notification': 0
    },
    {
      'avatar': 'Momo_images/Romeo.png',
      'name': 'Rider Ben',
      'message': 'Aight, noted',
      'time': '17/6',
      'notification': 1
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filtered chat list based on search query
    final filteredChats = chats
        .where((chat) =>
            chat['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '\n', // Add an empty line
              ),
              TextSpan(
                text: '\t\tMessages', // Add tab and the actual text
                style: TextStyle(
                  fontSize: 28, // Adjust font size
                  fontWeight: FontWeight.bold, // Make it bold
                  color: Colors.black, // Optional: change text color
                ),
              ),
            ],
          ),
          textAlign: TextAlign.start, // Optional: Align text to the start
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
                    'Momo_images/Vector.png',
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: filteredChats.map((chat) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/messengerconsumer',
                            arguments: chat['name']);
                      },
                      child: ChatCard(
                        avatar: chat['avatar'],
                        name: chat['name'],
                        message: chat['message'],
                        time: chat['time'],
                        notification: chat['notification'],
                      ),
                    );
                  }).toList(),
                ),
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
              Navigator.pushNamed(context, '/consumerHome');
            },
            child: Image.asset('Momo_images/home.png'),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/listconsumer');
            },
            child: Image.asset('Momo_images/My list.png'),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/chatconsumer');
            },
            child: Image.asset('Momo_images/chat.png'),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/consumerprofile');
            },
            child: Image.asset('Momo_images/profile.png'),
          ),
        ],
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.avatar,
    required this.name,
    required this.message,
    required this.time,
    required this.notification,
  });

  final String avatar;
  final String name;
  final String message;
  final String time;
  final int notification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: AssetImage(avatar),
                radius: 25,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                if (notification > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: Text(
                      notification.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
