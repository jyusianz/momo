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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momo Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Momo Chat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> _messages = [];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String message) {
    if (message.isEmpty) return;
    setState(() {
      _messages.add({'message': message, 'isSent': true});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('Momo_images/back.png', height: 30, width: 30),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        title: Row(
          children: [
            Image.asset(
              'Momo_images/momowhite.png', // Replace with your actual image path
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              'MOMO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '• Online',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[300],
      ),
      body: Container(
        color: Colors.green[100],
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _sendMessage(_controller.text);
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
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
          if (isSent) const SizedBox(width: 80),
          if (!isSent) const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSent ? Colors.green[300] : Colors.white,
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isSent ? Colors.white : Colors.black,
              ),
            ),
          ),
          if (isSent) const SizedBox(width: 20),
          if (!isSent) const SizedBox(width: 80),
        ],
      ),
    );
  }
}
