import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food/firebase/firebase_auth_service.dart';
import 'package:intl/intl.dart';
import 'package:food/showlistconsumer.dart';

class ConsumerHome extends StatefulWidget {
  const ConsumerHome({super.key});

  @override
  State<ConsumerHome> createState() => _ConsumerHomeState();
}

class _ConsumerHomeState extends State<ConsumerHome> {
  String _userName = 'User'; // Default name
  bool _isEditing = false; // To track editing state

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Fetch the user's name from Firestore
  Future<void> _fetchUserName() async {
    if (globalUID != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Consumer')
            .doc(globalUID!)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['User Name'];
          });
        } else {
          print('User document not found');
        }
      } catch (e) {
        print('Error fetching user name: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: Image.asset('Momo_images/Account.png'),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3DBC96),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '"Ready to restock? Whats on your grocery list today?"',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/inputlistconsumer');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
                child: const Text(
                  '  + Create a New List         ',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              // Added padding
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Align items
                children: [
                  const Text(
                    'My Lists',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Edit button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    child: Text(_isEditing ? 'Done' : 'Edit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildListsStream(),
            const SizedBox(height: 32),
          ],
        ),
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

  // Build the stream of lists from Firestore
  Widget _buildListsStream() {
    if (globalUID == null) {
      return const Center(
        child: Text("No lists available."),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Consumer')
          .doc(globalUID!)
          .collection('List')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No lists available."),
          );
        }

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            return ListCard(
              title: data['Title'],
              createdAt: data['createdAt'],
              itemCount: data['itemCount'] ?? 0,
              isEditing: _isEditing, // Pass the editing state to ListCard
              onTap: () {
                // Pass the lid (document ID) to Showlistconsumer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Showlistconsumer(lid: document.id),
                  ),
                );
              },
              onDelete: () {
                _showDeleteConfirmationDialog(document.id, data['Title']);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // Show the delete confirmation dialog
  void _showDeleteConfirmationDialog(String lid, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete the list '$title'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Delete the list from Firestore
                  await FirebaseFirestore.instance
                      .collection('Consumer')
                      .doc(globalUID!)
                      .collection('List')
                      .doc(lid)
                      .delete();
                  print("List with ID $lid deleted successfully.");

                  // Close the dialog
                  Navigator.pop(context);
                } catch (e) {
                  print("Error deleting list: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error deleting list.")),
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

class ListCard extends StatelessWidget {
  final String title;
  final Timestamp? createdAt;
  final int itemCount;
  final VoidCallback onTap;
  final VoidCallback onDelete; // To handle delete action
  final bool isEditing; // To control the visibility of the delete icon

  const ListCard({
    required this.title,
    required this.createdAt,
    required this.itemCount,
    required this.onTap,
    required this.onDelete,
    required this.isEditing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items
            children: [
              // Column for list details (title, date, item count)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    createdAt != null
                        ? DateFormat('yyyy-MM-dd HH:mm')
                            .format(createdAt!.toDate())
                        : 'Not created yet',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$itemCount items',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              // Conditionally show the delete icon
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
