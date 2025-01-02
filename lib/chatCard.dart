import 'package:flutter/material.dart';

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
      child: SizedBox(
        height: 100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 5, 10),
                child: CircleAvatar(
                  backgroundImage: AssetImage(avatar),
                  radius: 30,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (notification > 0)
                Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Align vertically
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
      ),
    );
  }
}
