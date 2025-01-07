import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Momo/firebase/firebase_auth_service.dart';
import 'orderConfirmationPage2.dart'; // Import the next page

class OrderConfirmationPage1 extends StatefulWidget {
  final String orderId;

  const OrderConfirmationPage1({super.key, required this.orderId});

  @override
  State<OrderConfirmationPage1> createState() => _OrderConfirmationPage1State();
}

class _OrderConfirmationPage1State extends State<OrderConfirmationPage1> {
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemVolumeController = TextEditingController();
  final _itemWeightController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  final _itemSpecialInstructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateOrderFields(); // Update order fields when the widget initializes
  }

  // Update the order document with initial values
  Future<void> _updateOrderFields() async {
    try {
      // 1. Get a reference to the order document
      final orderRef =
          FirebaseFirestore.instance.collection('Orders').doc(widget.orderId);

      // 2. Fetch the order document to get the ListId
      final orderDoc = await orderRef.get();
      final listId = orderDoc.get('listID'); // Get the ListId

      // 3. Get the item count from the Items subcollection
      final itemsSnapshot = await orderRef.collection('Items').get();
      final itemCount = itemsSnapshot.docs.length; // Get the actual count

      // 4. Update the order document with initial values
      await orderRef.update({
        'OrderId': widget.orderId,
        'ListId': listId, // Use the fetched ListId
        'userId': globalUID,
        'orderedAt': Timestamp.now(),
        'riderId': '',
        'isTaken': false,
        'isPlaced': false,
        'deliveryAddress': '',
        'fullName': '',
        'isCompleted': false,
        'market': '',
        'itemCount': itemCount, // Set the correct itemCount
        'estTotal': '',
      });

      print("Order fields updated successfully.");
    } catch (e) {
      print("Error updating order fields: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating order fields.")),
      );
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _itemVolumeController.dispose();
    _itemWeightController.dispose();
    _itemQuantityController.dispose();
    _itemSpecialInstructionsController.dispose();
    super.dispose();
  }

  // Build the AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '\n', // Add an empty line
            ),
            TextSpan(
              text: '\t\tReview Order\n', // Add tab and the actual text
              style: TextStyle(
                fontSize: 24, // Adjust font size
                fontWeight: FontWeight.bold, // Make it bold
                color: Colors.black, // Optional: change text color
              ),
            ),
          ],
        ),
        textAlign: TextAlign.start, // Optional: Align text to the start
      ),
    );
  }

  // Build the body of the Scaffold
  Widget _buildBody() {
    return Column(
      children: [
        //Add Item Button
        _buildAddItemButton(),
        const SizedBox(height: 16.0),
        //Expanded to allow list to take available space
        Expanded(
          child: _buildItemsList(),
        ),
        // Cancel Order and Continue buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red color for Cancel
                ),
                onPressed: () async {
                  // 1. Delete the order document and its items
                  await _deleteOrderAndItems();

                  // 2. Navigate back to the original list
                  Navigator.pop(context);
                },
                child: const Text("Cancel Order"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Green color for Continue
                ),
                onPressed: () {
                  // Navigate to OrderConfirmationPage2
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderConfirmationPage2(
                        orderId: widget.orderId,
                      ),
                    ),
                  );
                },
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build the "Add Item" button
  Widget _buildAddItemButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Add padding around the button
      child: Align(
        alignment: Alignment.centerLeft, // Align to the left
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
      ),
    );
  }

  // Build the list of items
  Widget _buildItemsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
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
          return const Center(
            child: Text(
              "No items in this order yet.",
              style: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          );
        }

        return ListView(
          shrinkWrap: false,
          //physics: const ClampingScrollPhysics(), // Use ClampingScrollPhysics
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final itemId = document.id;
            data['itemId'] = itemId;

            return OrderCard(
              itemId: itemId,
              orderName: data['Name'],
              description: data['Description'],
              weight: data['Weight'].toString(),
              volume: data['Volume'].toString(),
              item: data['Quantity'].toString(),
              specialInstructions: data['Special Instructions'],
              onTap: () {
                _showItemDetailsDialog(data);
              },
              onDelete: () {
                _deleteItem(itemId);
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

  // Show the "Add/Edit Item" dialog
  void _showAddOrEditItemDialog({String? itemId}) {
    if (itemId != null) {
      // If editing, fetch the item data from Firestore
      FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
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

  // Show the dialog for adding or editing an item
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
              _addOrEditItem(itemId: itemId);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Add or edit an item in Firestore
  void _addOrEditItem({String? itemId}) async {
    try {
      final item = {
        'Name': _itemNameController.text.trim(),
        'Description': _itemDescriptionController.text.trim(),
        'Volume': double.tryParse(_itemVolumeController.text.trim()) ?? 0,
        'Weight': double.tryParse(_itemWeightController.text.trim()) ?? 0,
        'Quantity': int.tryParse(_itemQuantityController.text.trim()) ?? 1,
        'Special Instructions': _itemSpecialInstructionsController.text.trim(),
      };

      // Get a reference to the order document
      final orderRef =
          FirebaseFirestore.instance.collection('Orders').doc(widget.orderId);

      if (itemId != null) {
        // Editing existing item
        await orderRef.collection('Items').doc(itemId).update(item);
        print("Item with ID $itemId updated successfully.");
      } else {
        // Adding new item
        await orderRef.collection('Items').add(item);
        print("New item added successfully.");

        // Increment item count in the order document
        await _updateItemCount(1);
      }
    } catch (e) {
      print("Error adding/editing item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error adding/editing item.")),
      );
    }
  }

  // Delete an item from Firestore
  Future<void> _deleteItem(String itemId) async {
    try {
      // Show confirmation dialog before deleting
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text("Are you sure you want to delete this item?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  // Delete the item if the user confirms
                  await FirebaseFirestore.instance
                      .collection('Orders')
                      .doc(widget.orderId)
                      .collection('Items')
                      .doc(itemId)
                      .delete();
                  print("Item with ID $itemId deleted successfully.");

                  // Decrement item count in the order document
                  await _updateItemCount(-1);

                  // Close the dialog
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error deleting item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting item.")),
      );
    }
  }

  // Update the item count in the order document
  Future<void> _updateItemCount(int change) async {
    try {
      // Get a reference to the order document
      final orderRef =
          FirebaseFirestore.instance.collection('Orders').doc(widget.orderId);

      // Use a transaction to ensure atomicity
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot orderDoc = await transaction.get(orderRef);

        // Check if the document exists
        if (!orderDoc.exists) {
          print("Order document ${widget.orderId} does not exist!");
          return;
        }

        int currentCount = orderDoc['itemCount'] ?? 0;
        int newCount = currentCount + change;

        print(
            "Updating item count for order ${widget.orderId} from $currentCount to $newCount");

        transaction.update(orderRef, {'itemCount': newCount});
      });
    } catch (e) {
      print('Error updating item count: $e');
    }
  }

  // Show a dialog with item details
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

  // Build a row for item details
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

  // Build a TextField widget
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // Delete the order document and its items
  Future<void> _deleteOrderAndItems() async {
    try {
      // 1. Get a reference to the order document
      final orderRef =
          FirebaseFirestore.instance.collection('Orders').doc(widget.orderId);

      // 2. Delete the items subcollection
      final itemsSnapshot = await orderRef.collection('Items').get();
      for (var itemDoc in itemsSnapshot.docs) {
        await itemDoc.reference.delete();
      }

      // 3. Delete the order document itself
      await orderRef.delete();

      print("Order with ID ${widget.orderId} deleted successfully.");
    } catch (e) {
      print("Error deleting order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting order.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }
}

// Widget for displaying an order card
class OrderCard extends StatelessWidget {
  final String itemId;
  final String orderName;
  final String description;
  final String weight;
  final String volume;
  final String item;
  final String specialInstructions;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const OrderCard({
    required this.itemId,
    required this.orderName,
    required this.description,
    required this.weight,
    required this.volume,
    required this.item,
    required this.specialInstructions,
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              if (weight.isNotEmpty) Text("Weight: $weight"),
              if (volume.isNotEmpty) Text("Volume: $volume"),
              Text("Quantity: $item"),
              if (specialInstructions.isNotEmpty)
                Text("Special Instructions: $specialInstructions"),
            ],
          ),
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
