import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food/firebase/firebase_auth_service.dart';
import 'package:intl/intl.dart';
import 'package:food/showlistconsumer.dart';
import 'package:food/folderpage.dart'; // Import the FolderPage

class ConsumerHome extends StatefulWidget {
  const ConsumerHome({super.key});

  @override
  State<ConsumerHome> createState() => _ConsumerHomeState();
}

class _ConsumerHomeState extends State<ConsumerHome> {
  String _userName = 'User'; // Default name
  bool _isEditing = false; // To track editing state for lists
  bool _isFolderEditing = false; // To track editing state for folders
  List<String> _folderNames = ['Unclassified'];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchFolderNames();
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

  // Fetch folder names from Firestore, create "Unclassified" if none exist
  Future<void> _fetchFolderNames() async {
    if (globalUID != null) {
      try {
        final foldersSnapshot = await FirebaseFirestore.instance
            .collection('Consumer')
            .doc(globalUID!)
            .collection('Folders')
            .get();

        if (foldersSnapshot.docs.isEmpty) {
          // Create "Unclassified" folder if none exist
          await FirebaseFirestore.instance
              .collection('Consumer')
              .doc(globalUID!)
              .collection('Folders')
              .add({'Name': 'Unclassified'});
        }

        setState(() {
          _folderNames =
              foldersSnapshot.docs.map((doc) => doc['Name'] as String).toList();
        });
      } catch (e) {
        print('Error fetching folder names: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/inputlistconsumer');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('  + Create a New List  '),
            ),
          ),
          const SizedBox(height: 32),

          // "My Lists" text is now above the tabs
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'My Lists',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tabs Section
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: "All"),
                      Tab(text: "Folder"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1 content with Edit button
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
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
                            Expanded(
                              child: _buildListsStream(),
                            ),
                          ],
                        ),
                        // Tab 2 content with Edit button
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isFolderEditing = !_isFolderEditing;
                                    });
                                  },
                                  child:
                                      Text(_isFolderEditing ? 'Done' : 'Edit'),
                                ),
                              ],
                            ),
                            Expanded(
                              child: _buildFoldersStream(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
            child: Image.asset('Momo_images/orders.png'),
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
          shrinkWrap: false,
          //physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            return ListCard(
              title: data['Title'],
              createdAt: data['createdAt'],
              itemCount: data['itemCount'] ?? 0,
              isEditing: _isEditing,
              onTap: () {
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

  // Build the stream of folders from Firestore
  Widget _buildFoldersStream() {
    if (globalUID == null) {
      return const Center(
        child: Text("No folders available."),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Consumer')
          .doc(globalUID!)
          .collection('Folders')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // If no folders are available, show the default "Unclassified" folder
          return ListView(
            shrinkWrap: false,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              FolderCard(
                folderName: 'Unclassified',
                isEditing: _isFolderEditing,
                onDelete: () {
                  _showDeleteFolderConfirmationDialog('Unclassified');
                },
                onTap: () {
                  // Navigate to FolderPage for "Unclassified"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const FolderPage(folderName: 'Unclassified'),
                    ),
                  );
                },
              ),
            ],
          );
        }

        return ListView(
          shrinkWrap: true,
          //physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            return FolderCard(
              folderName: data['Name'],
              isEditing: _isFolderEditing,
              onDelete: () {
                _showDeleteFolderConfirmationDialog(data['Name']);
              },
              onTap: () {
                // Navigate to FolderPage and pass the folderName
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FolderPage(
                      folderName: data['Name'],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  // Show the delete confirmation dialog for lists
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

  // Show the delete confirmation dialog for folders
  void _showDeleteFolderConfirmationDialog(String folderName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text(
              "Are you sure you want to delete the folder '$folderName'?\nThis will also delete all lists inside this folder."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // 1. Delete the lists within the folder
                  final listsSnapshot = await FirebaseFirestore.instance
                      .collection('Consumer')
                      .doc(globalUID!)
                      .collection('List')
                      .where('folder', isEqualTo: folderName)
                      .get();

                  for (DocumentSnapshot listDoc in listsSnapshot.docs) {
                    await listDoc.reference.delete();
                  }

                  // 2. Delete the folder from Firestore
                  await FirebaseFirestore.instance
                      .collection('Consumer')
                      .doc(globalUID!)
                      .collection('Folders')
                      .where('Name', isEqualTo: folderName)
                      .get()
                      .then((snapshot) {
                    for (DocumentSnapshot ds in snapshot.docs) {
                      ds.reference.delete();
                    }
                  });
                  print("Folder '$folderName' deleted successfully.");

                  // Fetch the updated folder names after deleting
                  await _fetchFolderNames();

                  // Close the dialog
                  Navigator.pop(context);
                } catch (e) {
                  print("Error deleting folder: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error deleting folder.")),
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
  final VoidCallback onDelete;
  final bool isEditing;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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

class FolderCard extends StatelessWidget {
  final String folderName;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isEditing;

  const FolderCard({
    required this.folderName,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                folderName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
