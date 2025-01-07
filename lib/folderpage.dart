import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Momo/firebase/firebase_auth_service.dart';
import 'package:intl/intl.dart';
import 'package:Momo/showlistconsumer.dart';

class FolderPage extends StatefulWidget {
  final String folderName; // To receive the folder name

  const FolderPage({super.key, required this.folderName});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  bool _isEditing = false; // To track editing state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
        actions: [
          // Edit button in the AppBar
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
      body: _buildListsInFolderStream(),
    );
  }

  // Build the stream of lists within the folder from Firestore
  Widget _buildListsInFolderStream() {
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
          .where('folder',
              isEqualTo: widget.folderName) // Filter by folder name
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
            child: Text("No lists available in this folder."),
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
