import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Momo/shoppingInProgress.dart';
//import 'package:url_launcher/url_launcher.dart';

class RiderOrderConfirmationPage extends StatefulWidget {
  final String orderId;

  const RiderOrderConfirmationPage({super.key, required this.orderId});

  @override
  State<RiderOrderConfirmationPage> createState() =>
      _RiderOrderConfirmationPageState();
}

class _RiderOrderConfirmationPageState
    extends State<RiderOrderConfirmationPage> {
  String? orderId;
  String? _riderName;
  String? _riderPhoneNumber;
  //bool _isShoppingStarted = false;
  //Map<String, dynamic>? _orderData; // Define _orderData
  //List<Map<String, dynamic>> _items = []; // Define _items

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      setState(() {
        orderId = args; // Assign the received argument to orderId
      });
      print(orderId);
      _getOrderDetails();
    } else {
      // Handle the case where orderId is null or of the wrong type
      print('Error: orderId is null or of incorrect type');
      // You might want to navigate back or show an error message
    }
  }

  Future<void> _updateShoppingState() async {
    try {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .update({
        'isShoppingStarted': true,
      });
    } catch (e) {
      print('Error updating shopping state: $e');
    }
  }

  Future<void> _getOrderDetails() async {
    try {
      print(orderId);
      final orderDoc = await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .get();

      if (orderDoc['isTaken'] == true && orderDoc['riderId'] != null) {
        final riderId = orderDoc['riderId'];
        final riderDoc = await FirebaseFirestore.instance
            .collection('Rider')
            .doc(riderId)
            .get();

        setState(() {
          // Add setState here
          _riderName = riderDoc['First Name'] != null
              ? riderDoc['First Name'] + ' ' + riderDoc['Last Name']
              : 'Unknown Rider'; // Or handle the missing name appropriately
          _riderPhoneNumber = riderDoc['Mobile Number'];
        });
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  Widget _buildOrderTakenContent(DocumentSnapshot orderDoc) {
    return Column(
      children: [
        // Image for order taken
        Image.asset(
          'Momo_images/ordertaken.png', // Replace with your image path
          height: 100,
          width: 100,
        ),
        const SizedBox(height: 16),
        Text(
          "Rider $_riderName has taken this order.",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Display rider information
        Text("Rider Name: $_riderName"),
        Text("Phone Number: $_riderPhoneNumber"),
      ],
    );
  }

  Widget _buildOrderDetails(DocumentSnapshot orderDoc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          "${orderDoc['firstName']} ${orderDoc['lastName']}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text("${orderDoc['mobileNumber']}"),
        Text("${orderDoc['deliveryAddress']}"),
        const Divider(), // Add a divider line here
        const SizedBox(height: 8), // Add some space after the divider

        // Display the market name (since it's already available)
        Text(orderDoc['market'], style: const TextStyle(fontSize: 14)),
        // Fetch and display market address
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
        _buildItemsList(orderDoc), // Pass the orderDoc to _buildItemsList
      ],
    );
  }

  // Build the list of items
  Widget _buildItemsList(DocumentSnapshot orderDoc) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
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
          return const Center(
            child: Text("No items in this order."),
          );
        }

        return Column(
          children: [
            FutureBuilder<List<Widget>>(
              future: _buildItemTiles(snapshot.data!.docs, orderDoc['market']),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (futureSnapshot.hasError) {
                  return Text('Error: ${futureSnapshot.error}');
                } else {
                  return Column(children: futureSnapshot.data!);
                }
              },
            ),
            // Price Summary
            _buildPriceSummary(orderDoc,
                snapshot), // Add this line to include the price summary
          ],
        );
      },
    );
  }

  // Calculate the service fee based on the tiered structure
  double calculateServiceFee(double subtotal) {
    if (subtotal < 200) {
      return 20;
    } else if (subtotal < 500) {
      return 40;
    } else if (subtotal < 1000) {
      return 75;
    } else if (subtotal < 2000) {
      return 120;
    } else if (subtotal < 3000) {
      return 180;
    } else {
      return 250;
    }
  }

// Add this new method to show the fee information dialog
  void _showFeeInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Modified _buildPriceSummary() to add info buttons and accept snapshot
  Widget _buildPriceSummary(
      DocumentSnapshot orderDoc, AsyncSnapshot<QuerySnapshot> snapshot) {
    double subtotal = 0;
    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      for (var document in snapshot.data!.docs) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        subtotal += data['totalPrice'] ?? 0;
      }
    }

    double deliveryFee = 60;
    double serviceFee = calculateServiceFee(subtotal);
    double total = subtotal + deliveryFee + serviceFee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          "Subtotal: ₱${subtotal.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          children: [
            Text(
              "Delivery Fee: ₱${deliveryFee.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              onPressed: () => _showFeeInfoDialog(
                context,
                "Delivery Fee Information",
                "The delivery fee covers the cost of transporting your items from the supermarket to your delivery address. This includes fuel, maintenance, and our delivery partner's compensation.",
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "Service Fee: ₱${serviceFee.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              onPressed: () => _showFeeInfoDialog(
                context,
                "Service Fee Information",
                "The service fee helps us maintain the platform and provide customer support. It varies based on your order subtotal:\n\n"
                    "• Under ₱200: ₱20\n"
                    "• ₱200-499: ₱40\n"
                    "• ₱500-999: ₱75\n"
                    "• ₱1000-1999: ₱120\n"
                    "• ₱2000-2999: ₱180\n"
                    "• ₱3000+: ₱250",
              ),
            ),
          ],
        ),
        const Divider(),
        Text(
          "Total: ₱${total.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper function to build item tiles asynchronously
  Future<List<Widget>> _buildItemTiles(
      List<QueryDocumentSnapshot> docs, String marketName) async {
    List<Widget> tiles = [];
    for (var document in docs) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      final itemId = document.id;
      data['itemId'] = itemId;
      // Get the estimated price for this item
      double estimatedPrice = await getEstimatedPrice(data, marketName);
      double itemTotal = estimatedPrice * data['Quantity'];

      tiles.add(
        ListTile(
          title: Text(data['Name']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display other item details with smaller font size
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
                  style: const TextStyle(fontSize: 12),
                ),
              // Display estimated price (srPrice)
              Text(
                "Estimated Price: ₱${estimatedPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 14),
              ),
              // Display total price for this item (totalPrice)
              Text(
                "Item Total: ₱${itemTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return tiles;
  }

  // Fetch products for a given market from Firestore
  Future<List<Map<String, dynamic>>> fetchMarketProducts(
      String marketName) async {
    // 1. Get the marketId for the selected marketName (using async/await)
    String marketId = await _getMarketIdFromName(marketName);

    // 2. Fetch products from the 'Products' subcollection within the market document
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(marketId) // Access the market document using marketId
          .collection('Products') // Access the 'Products' subcollection
          .get();

      // Convert the query result to a list of maps
      List<Map<String, dynamic>> products =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      return products;
    } catch (e) {
      print('Error fetching market products: $e');
      return []; // Or handle the error as needed
    }
  }

  // Helper function to get marketId from marketName
  Future<String> _getMarketIdFromName(String marketName) async {
    // Change return type to Future<String>
    try {
      // 1. Query the 'Markets' collection for the document with the matching marketName
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .where('Market Name', isEqualTo: marketName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 2. If a document is found, return its marketId
        return querySnapshot.docs.first.id;
      } else {
        // 3. If no document is found, return an empty string or handle the error appropriately
        print('No market found with name: $marketName');
        return '';
      }
    } catch (e) {
      print('Error fetching market ID: $e');
      return ''; // Or handle the error as needed
    }
  }

  // Calculate the estimated price for an item based on the selected market
  Future<double> getEstimatedPrice(
      // Change return type to Future<double>
      Map<String, dynamic> itemData,
      String marketName) async {
    // 1. Fetch products for the selected market from your database
    List<Map<String, dynamic>> marketProducts =
        await fetchMarketProducts(marketName); // Await the result

    // 2. Find the matching product in the marketProducts list
    for (var product in marketProducts) {
      if (product['Product Name'] == itemData['Name']) {
        if (product['SRPrice'] is int) {
          return (product['SRPrice'] as int).toDouble();
        } else {
          return product['SRPrice'] as double; // Already a double
        }
      }
    }

    return 0.0; // Return 0 if no match is found
  }

  // Helper function to get market address from marketName
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
        print('No market found with name: $marketName');
        return '';
      }
    } catch (e) {
      print('Error fetching market address: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Summary"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              Navigator.pushReplacementNamed(context, '/riderHome');
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .doc(orderId)
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildOrderTakenContent(orderDoc),
                _buildOrderDetails(orderDoc),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching order status'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          bool isCompleted = snapshot.data?['isCompleted'] ?? false;
          bool isShoppingStarted = snapshot.data?['isShoppingStarted'] ?? false;

          return Container(
            padding: const EdgeInsets.all(16.0),
            // color: isCompleted ? Colors.grey : Colors.green,
            child: ElevatedButton(
              onPressed: isCompleted
                  ? null
                  : () async {
                      await _updateShoppingState();
                      // 1. Navigate to the next page ("Shopping in Progress")
                      // Correct way to navigate
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShoppingInProgressPage(orderId: orderId!),
                        ),
                      );

                      // 2. Update button state
                      setState(() {
                        isShoppingStarted = true;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                isCompleted
                    ? "Finished Order"
                    : (isShoppingStarted
                        ? "Continue Shopping"
                        : "Start Shopping"),
              ),
            ),
          );
        },
      ),
    );
  }
}
