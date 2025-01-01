import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Messengerconsumer()),
              );
            },
            child: const Text('Open Momo Chat'),
          ),
        ),
      ),
    );
  }
}

class Messengerconsumer extends StatefulWidget {
  const Messengerconsumer({super.key});

  @override
  State<Messengerconsumer> createState() => _MessengerconsumerState();
}

class _MessengerconsumerState extends State<Messengerconsumer> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return; // Prevent sending empty messages
    setState(() {
      _messages.add({'message': message.trim(), 'isSent': true});
    });
    _controller.clear(); // Clear the text field after sending
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: Image.asset('Momo_images/back.png', height: 30, width: 30),
              onPressed: () {
                Navigator.pop(context); // Back button functionality
              },
            ),
            const SizedBox(width: 10),
            const CircleAvatar(
              backgroundImage: AssetImage('Momo_images/Juan_Deck.png'),
              radius: 20,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rider',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 251, 252, 251),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length, // Dynamic message count
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatMessage(
                    message: message['message'],
                    isSent: message['isSent'],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Write a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _sendMessage(_controller.text); // Call _sendMessage
                      },
                      icon: Image.asset(
                        'Momo_images/send.png',
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isSent;

  const ChatMessage({super.key, required this.message, required this.isSent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSent) const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSent
                  ? const Color.fromARGB(255, 40, 146, 114)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isSent ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          if (isSent) const SizedBox(width: 20),
        ],
      ),
    );
  }
}
