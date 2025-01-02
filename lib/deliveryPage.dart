import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Deliverypage extends StatefulWidget {
  final String orderId;

  const Deliverypage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<Deliverypage> createState() => _DeliverypageState();
}

class _DeliverypageState extends State<Deliverypage> {
  String? _riderName;
  String? _riderPhoneNumber;
  Map<String, dynamic>? _orderData;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _getOrderDetails();
  }

  Future<void> _getOrderDetails() async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .get();

      if (orderDoc.exists) {
        setState(() {
          _orderData = orderDoc.data() as Map<String, dynamic>;
        });

        if (orderDoc['riderId'] != null) {
          final riderId = orderDoc['riderId'];
          final riderDoc = await FirebaseFirestore.instance
              .collection('Rider')
              .doc(riderId)
              .get();

          setState(() {
            _riderName = riderDoc['First Name'] + ' ' + riderDoc['Last Name'];
            _riderPhoneNumber = riderDoc['Mobile Number'];
          });
        }

        final itemsSnapshot = await FirebaseFirestore.instance
            .collection('Orders')
            .doc(widget.orderId)
            .collection('Items')
            .get();

        setState(() {
          _items = itemsSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  // Removed _toggleItemStatus and _calculateTotalPrice functions

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

  Future<void> _DeliveredOrder() async {
    try {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .update({
        'isDelivered': true,
      });

      Navigator.pushReplacementNamed(
        context,
        '/riderHome',
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
        title: const Text("Order Progress"),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Picture and Text
            Center(
              child: Image.asset(
                'Momo_images/deliver.png', // Replace with your actual image path
                height: 130,
                width: 130,
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                "Now deliver the grocery to ${_orderData!['firstName']} ${_orderData!['lastName']}.",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            StreamBuilder<DocumentSnapshot>(
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
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _DeliveredOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text("Done Delivered"),
        ),
      ),
    );
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
          "Items:",
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

        // Filter items where isChecked is true
        final checkedItems = snapshot.data!.docs
            .where((doc) => doc.data() != null && doc['isChecked'] == true)
            .toList();

        if (checkedItems.isEmpty) {
          return const Center(child: Text("No checked items."));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: checkedItems.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data =
                checkedItems[index].data() as Map<String, dynamic>;

            return Card(
              child: ListTile(
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
              ),
            );
          },
        );
      },
    );
  }
}
