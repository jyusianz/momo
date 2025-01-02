import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food/deliveryPage.dart';
import 'package:url_launcher/url_launcher.dart';

class ShoppingInProgressPage extends StatefulWidget {
  final String orderId;

  const ShoppingInProgressPage({Key? key, required this.orderId})
      : super(key: key);

  @override
  State<ShoppingInProgressPage> createState() => _ShoppingInProgressPageState();
}

class _ShoppingInProgressPageState extends State<ShoppingInProgressPage> {
  String? _riderName;
  String? _riderPhoneNumber;
  Map<String, bool> checkedItems = {};
  bool _showDropdown = false;
  String _selectedAction = 'chat';
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemVolumeController = TextEditingController();
  final _itemWeightController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  final _itemSpecialInstructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getOrderDetails();
    _loadCheckedStates();
  }

  Future<void> _loadCheckedStates() async {
    try {
      final itemsSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .collection('Items')
          .get();

      Map<String, bool> loadedStates = {};
      for (var doc in itemsSnapshot.docs) {
        loadedStates[doc.id] = doc.data()['isChecked'] ?? false;
      }

      setState(() {
        checkedItems = loadedStates;
      });
    } catch (e) {
      print('Error loading checked states: $e');
    }
  }

  Future<void> _updateCheckedState(String itemId, bool isChecked) async {
    try {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .collection('Items')
          .doc(itemId)
          .update({'isChecked': isChecked});
    } catch (e) {
      print('Error updating checked state: $e');
      // Revert the checkbox state if save fails
      setState(() {
        checkedItems[itemId] = !isChecked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save item state. Please try again.')),
      );
    }
  }

  Future<void> _getOrderDetails() async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .get();

      if (orderDoc['riderId'] != null) {
        final riderId = orderDoc['riderId'];
        final riderDoc = await FirebaseFirestore.instance
            .collection('Rider')
            .doc(riderId)
            .get();

        setState(() {
          _riderName = riderDoc['First Name'] != null
              ? riderDoc['First Name'] + ' ' + riderDoc['Last Name']
              : 'Unknown Rider';
          _riderPhoneNumber = riderDoc['Mobile Number'];
        });
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  Widget _buildOrderDetails(DocumentSnapshot orderDoc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Rider Information
        Text(
          "Rider Information:",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text("Name: $_riderName"),
        Text("Phone: $_riderPhoneNumber"),
        const Divider(),

        // Consumer Information
        Text(
          "Consumer Information:",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "${orderDoc['firstName']} ${orderDoc['lastName']}",
          style: const TextStyle(fontSize: 14),
        ),
        Text("${orderDoc['mobileNumber']}"),
        Text("${orderDoc['deliveryAddress']}"),
        const Divider(),

        // Market Information
        Text(orderDoc['market'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        FutureBuilder<String>(
          future: _getMarketAddress(orderDoc['market']),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!, style: TextStyle(fontSize: 12));
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          "Shopping List:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        _buildItemsList(orderDoc),
      ],
    );
  }

  Widget _buildItemsList(DocumentSnapshot orderDoc) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .collection('Items')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No items in this order."));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            return Card(
              child: CheckboxListTile(
                value: checkedItems[doc.id] ?? false,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      checkedItems[doc.id] = value;
                    });
                    _updateCheckedState(doc.id, value);
                  }
                },
                title: Text(data['Name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['Description'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (data['Weight'] != null)
                      Text(
                        "Weight: ${data['Weight']}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    if (data['Volume'] != null)
                      Text(
                        "Volume: ${data['Volume']}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    Text(
                      "Quantity: ${data['Quantity']}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (data['Special Instructions'] != null)
                      Text(
                        "Special Instructions: ${data['Special Instructions']}",
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                  ],
                ),
                secondary: _buildTrailingWidget(doc.id, data),
              ),
            );
          },
        );
      },
    );
  }

  void _showContactDialog(String itemId, Map<String, dynamic> itemData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Item: ${itemData['Name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _selectedAction,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAction = newValue!;
                    switch (_selectedAction) {
                      case 'chat':
                        print('Chat with consumer about ${itemData['Name']}');
                        break;
                      case 'edit':
                        _showEditItemDialog(itemId, itemData);
                        break;
                    }
                    Navigator.pop(context);
                  });
                },
                items: <String>['chat', 'edit']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditItemDialog(String itemId, Map<String, dynamic> itemData) {
    _itemNameController.text = itemData['Name'];
    _itemDescriptionController.text = itemData['Description'];
    _itemVolumeController.text = itemData['Volume'].toString();
    _itemWeightController.text = itemData['Weight'].toString();
    _itemQuantityController.text = itemData['Quantity'].toString();
    _itemSpecialInstructionsController.text =
        itemData['Special Instructions'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("Name:", _itemNameController),
                _buildTextField("Description:", _itemDescriptionController),
                _buildTextField("Volume:", _itemVolumeController),
                _buildTextField("Weight:", _itemWeightController),
                _buildTextField("Quantity:", _itemQuantityController),
                _buildTextField(
                  "Special Instructions:",
                  _itemSpecialInstructionsController,
                ),
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
                try {
                  await FirebaseFirestore.instance
                      .collection('Orders')
                      .doc(widget.orderId)
                      .collection('Items')
                      .doc(itemId)
                      .update({
                    'Name': _itemNameController.text.trim(),
                    'Description': _itemDescriptionController.text.trim(),
                    'Volume':
                        double.tryParse(_itemVolumeController.text.trim()) ?? 0,
                    'Weight':
                        double.tryParse(_itemWeightController.text.trim()) ?? 0,
                    'Quantity':
                        int.tryParse(_itemQuantityController.text.trim()) ?? 1,
                    'Special Instructions':
                        _itemSpecialInstructionsController.text.trim(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item updated successfully!')),
                  );
                } catch (e) {
                  print('Error updating item: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update item.')),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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

  Future<String> _getMarketAddress(String marketName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .where('Market Name', isEqualTo: marketName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final marketDoc = querySnapshot.docs.first;
        return "${marketDoc['Address']}";
      } else {
        return '';
      }
    } catch (e) {
      print('Error fetching market address: $e');
      return '';
    }
  }

  Future<void> _completeOrder() async {
    try {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .update({
        'isCompleted': true,
      });

      print(widget.orderId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Deliverypage(orderId: widget.orderId),
        ),
      );
    } catch (e) {
      print('Error completing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete order. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Progress"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/riderHome');
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Order not found."));
          }

          final orderDoc = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderDetails(orderDoc),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _completeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text("Checkout"),
        ),
      ),
    );
  }

  // Helper function to build the trailing widget (dropdown or IconButton)
  Widget _buildTrailingWidget(String itemId, Map<String, dynamic> itemData) {
    if (_showDropdown) {
      return DropdownButton<String>(
        value: _selectedAction,
        onChanged: (String? newValue) {
          setState(() {
            _selectedAction = newValue!;
            switch (_selectedAction) {
              case 'chat':
                // Implement chat functionality here
                print('Chat with consumer about ${itemData['Name']}');
                break;
              case 'edit':
                // Show dialog to edit item
                _showEditItemDialog(itemId, itemData);
                break;
            }
            _showDropdown =
                false; // Hide the dropdown after selecting an action
          });
        },
        items: <String>['chat', 'edit']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          setState(() {
            _showDropdown =
                true; // Show the dropdown when the button is pressed
          });
        },
      );
    }
  }
}
