import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food/firebase/firebase_auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Inputlistconsumer extends StatefulWidget {
  const Inputlistconsumer({super.key});

  @override
  State<Inputlistconsumer> createState() => _InputlistconsumerState();
}

class _InputlistconsumerState extends State<Inputlistconsumer> {
  final _titleController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemVolumeController = TextEditingController();
  final _itemWeightController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  final _itemSpecialInstructionsController = TextEditingController();

  String? _currentLid;

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveItems(String lid, {String? itemId}) async {
    try {
      final itemNameString = _itemNameController.text.trim();
      final itemDescriptionString = _itemDescriptionController.text.trim();
      final itemVolume = double.tryParse(_itemVolumeController.text.trim());
      final itemWeight = double.tryParse(_itemWeightController.text.trim());
      final itemQuantity = int.tryParse(_itemQuantityController.text.trim());
      final itemSpecialInstructionsString =
          _itemSpecialInstructionsController.text.trim();

      final itemIdToSave =
          itemId ?? FirebaseFirestore.instance.collection('Items').doc().id;

      if (globalUID != null) {
        print(
            "Saving/Updating item with ID $itemIdToSave to: Consumer/$globalUID/List/$lid/Items/$itemIdToSave");
        await FirebaseFirestore.instance
            .collection('Consumer')
            .doc(globalUID!)
            .collection('List')
            .doc(lid)
            .collection('Items')
            .doc(itemIdToSave)
            .set({
          'Name': itemNameString,
          'Description': itemDescriptionString,
          'Volume': itemVolume ?? 0,
          'Weight': itemWeight ?? 0,
          'Quantity': itemQuantity ?? 1,
          'Special Instructions': itemSpecialInstructionsString,
        });
        print("Item with ID $itemIdToSave saved/updated successfully.");

        // Only increment when adding a new item
        //await _updateItemCount(lid, 1);
      } else {
        print("Error: User not logged in (globalUID is null)");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You need to log in first.")),
        );
        Navigator.pushNamed(context, '/signin_consumer');
      }
    } catch (e) {
      print("Error saving item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving item.")),
      );
    }
  }

  Future<void> saveLists() async {
    final titleString = _titleController.text.trim();

    if (globalUID != null) {
      if (_currentLid == null) {
        // No list exists, create a new document
        _currentLid = FirebaseFirestore.instance.collection('List').doc().id;
        await FirebaseFirestore.instance
            .collection('Consumer')
            .doc(globalUID!)
            .collection('List')
            .doc(_currentLid!)
            .set({
          'Title': titleString,
          'createdAt': Timestamp.now(),
          'itemCount': 0, // Initialize itemCount to 0
        });
      } else {
        // List exists, update the existing document
        await FirebaseFirestore.instance
            .collection('Consumer')
            .doc(globalUID!)
            .collection('List')
            .doc(_currentLid!)
            .update({'Title': titleString});
      }

      setState(() {});
    } else {
      // Handle the case where globalUID is null (user not logged in)
      print("Error: User not logged in (globalUID is null)");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to log in first.")),
      );

      Navigator.pushNamed(context, '/signin_consumer');
    }
  }

  Future<void> deleteItem(String lid, String itemId) async {
    try {
      if (globalUID != null) {
        print(
            "Deleting item with ID $itemId from: Consumer/$globalUID/List/$lid/Items/$itemId");
        await FirebaseFirestore.instance
            .collection('Consumer')
            .doc(globalUID!)
            .collection('List')
            .doc(lid)
            .collection('Items')
            .doc(itemId)
            .delete();
        print("Item with ID $itemId deleted successfully.");

        // Update item count in the list document
        await _updateItemCount(lid, -1);
      } else {
        print("Error: User not logged in (globalUID is null)");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You need to log in first.")),
        );
      }
    } catch (e) {
      print("Error deleting item collection: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting item.")),
      );
    }
  }

  Future<void> _updateItemCount(String lid, int change) async {
    try {
      // Get a reference to the list document
      final listRef = FirebaseFirestore.instance
          .collection('Consumer')
          .doc(globalUID!)
          .collection('List')
          .doc(lid);

      // Use a transaction to ensure atomicity
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot listDoc = await transaction.get(listRef);
        int currentCount = listDoc['itemCount'] ?? 0;
        transaction.update(listRef, {'itemCount': currentCount + change});

        // Check if the document exists
        if (!listDoc.exists) {
          print("List document $lid does not exist!"); // Debugging log
          return;
        }
        int newCount = currentCount + change;

        print(
            "Updating item count for list $lid from $currentCount to $newCount"); // Debugging log

        transaction.update(listRef, {'itemCount': newCount});
      });
    } catch (e) {
      print('Error updating item count: $e');
    }
  }

  final Map<String, XFile?> _itemImages = {};
  bool _isTitleEditable = false;

  @override
  void dispose() {
    _titleController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _itemVolumeController.dispose();
    _itemWeightController.dispose();
    _itemQuantityController.dispose();
    _itemSpecialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Image.asset('Momo_images/back.png'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
            icon: Image.asset('Momo_images/Check icon.png'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Save Your List'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Title',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: _titleController.text.trim(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const Text(
                          'Folder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            labelText: '',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(child: Text('Unclassified')),
                          ],
                          onChanged: (value) {},
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await saveLists();
                                Navigator.popUntil(context,
                                    ModalRoute.withName('/consumerHome'));
                              },
                              child: const Text('Save'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/orderlistrequestconsumer');
                              },
                              child: const Text('Save & Order'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          _buildTimestamp(),
          const SizedBox(height: 6.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAddItemButton(),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildImage(),
          const SizedBox(height: 20),
          _currentLid != null ? _buildItemsList() : _buildNoItemsText(),
          const SizedBox(height: 150),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isTitleEditable = !_isTitleEditable;
          });
        },
        child: AbsorbPointer(
          absorbing: !_isTitleEditable,
          child: TextField(
            controller: _titleController,
            readOnly: !_isTitleEditable,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Input Title',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        // Format the current date and time as needed
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAddItemButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 223, 236, 224),
          textStyle: const TextStyle(fontSize: 20, color: Colors.white),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        onPressed: () {
          _showAddOrEditItemDialog();
        },
        child: const Text('Add Item'),
      ),
    );
  }

  Widget _buildImage() {
    if (_currentLid == null) {
      return Center(
        child: Image.asset('Momo_images/find.png'),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _showItemDetailsDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['Name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Description:', data['Description']),
              _buildDetailRow('Volume:', data['Volume'].toString()),
              _buildDetailRow('Weight:', data['Weight'].toString()),
              _buildDetailRow('Quantity:', data['Quantity'].toString()),
              _buildDetailRow(
                  'Special Instructions:', data['Special Instructions']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddOrEditItemDialog(
                itemId: data['itemId'],
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildNoItemsText() {
    return const Center(
      child: Text(
        "No items on this list yet.",
        style: TextStyle(
          fontSize: 15,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Consumer')
          .doc(globalUID!)
          .collection('List')
          .doc(_currentLid!)
          .collection('Items')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoItemsText();
        }

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final itemId = document.id;
            data['itemId'] = itemId;

            return OrderCard(
              orderName: data['Name'],
              description: data['Description'],
              weight: data['Weight'].toString(),
              volume: data['Volume'].toString(),
              item: data['Quantity'].toString(),
              specialInstructions: data['Special Instructions'],
              imagePicker: '',
              onTap: () {
                _showItemDetailsDialog(data);
              },
              onDelete: () {
                deleteItem(_currentLid!, itemId);
              },
              onEdit: () {
                _showAddOrEditItemDialog(itemId: itemId);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showAddOrEditItemDialog({String? itemId}) {
    if (itemId != null) {
      // If editing, fetch the item data from Firestore
      FirebaseFirestore.instance
          .collection('Consumer')
          .doc(globalUID!)
          .collection('List')
          .doc(_currentLid)
          .collection('Items')
          .doc(itemId)
          .get()
          .then((doc) {
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _itemNameController.text = data['Name'];
          _itemDescriptionController.text = data['Description'];
          _itemVolumeController.text = data['Volume'].toString();
          _itemWeightController.text = data['Weight'].toString();
          _itemQuantityController.text = data['Quantity'].toString();
          _itemSpecialInstructionsController.text =
              data['Special Instructions'];
          // Show the dialog after fetching the data
          _showItemDialog(itemId: itemId);
        } else {
          print("Error: Item not found.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Item not found.")),
          );
        }
      }).catchError((error) {
        print("Error fetching item data: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching item data.")),
        );
      });
    } else {
      // If adding a new item, clear the fields
      _itemNameController.clear();
      _itemDescriptionController.clear();
      _itemVolumeController.clear();
      _itemWeightController.clear();
      _itemQuantityController.clear();
      _itemSpecialInstructionsController.clear();
      _showItemDialog(itemId: itemId);
    }
  }

  void _showItemDialog({String? itemId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.only(left: 30, right: 30),
        title: const Text('Add/Edit an item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              _buildTextField("Name:", _itemNameController),
              const SizedBox(height: 10),
              _buildTextField("Description:", _itemDescriptionController),
              const SizedBox(height: 10),
              _buildTextField("Volume:", _itemVolumeController),
              const SizedBox(height: 10),
              _buildTextField("Weight:", _itemWeightController),
              const SizedBox(height: 10),
              _buildTextField("Quantity:", _itemQuantityController),
              const SizedBox(height: 10),
              _buildTextField(
                "Special Instructions:",
                _itemSpecialInstructionsController,
              ),
              const SizedBox(height: 10),
              _buildAddPictureButton(),
              const SizedBox(height: 10),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_currentLid == null) {
                // No list exists, save the list first
                await saveLists();
              }
              // Now save the item
              if (_currentLid != null) {
                _addOrEditItem(itemId: itemId);
              } else {
                // Handle the case where list creation failed
                print("Error: Failed to create a list.");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error saving item.")),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addOrEditItem({String? itemId}) async {
    final item = {
      'Name': _itemNameController.text.trim(),
      'Description': _itemDescriptionController.text.trim(),
      'Volume': double.tryParse(_itemVolumeController.text.trim()) ?? 0,
      'Weight': double.tryParse(_itemWeightController.text.trim()) ?? 0,
      'Quantity': int.tryParse(_itemQuantityController.text.trim()) ?? 1,
      'Special Instructions': _itemSpecialInstructionsController.text.trim(),
    };

    if (itemId != null) {
      // Editing existing item
      await FirebaseFirestore.instance
          .collection('Consumer')
          .doc(globalUID!)
          .collection('List')
          .doc(_currentLid)
          .collection('Items')
          .doc(itemId)
          .update(item);
    } else {
      // Adding new item
      if (_currentLid != null && globalUID != null) {
        final newItemRef = await FirebaseFirestore.instance
            .collection('Consumer')
            .doc(globalUID!)
            .collection('List')
            .doc(_currentLid)
            .collection('Items')
            .add(item);

        print("New item added with ID: ${newItemRef.id}"); // Debugging log
        // Increment item count
        await _updateItemCount(_currentLid!, 1);
      }
    }
  }

  Widget _buildAddPictureButton() {
    return ElevatedButton(
      onPressed: _pickImage,
      child: const Text("Add Picture"),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _itemImages[_itemNameController.text] = pickedImage;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String orderName;
  final String description;
  final String weight;
  final String volume;
  final String item;
  final String specialInstructions;
  final String imagePicker;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const OrderCard({
    required this.orderName,
    required this.description,
    required this.weight,
    required this.volume,
    required this.item,
    required this.specialInstructions,
    required this.imagePicker,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          title: Text(orderName),
          subtitle: Text(description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
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
