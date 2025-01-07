import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Momo/firebase/firebase_auth_service.dart';
import 'package:Momo/utils/chatService.dart';
import 'package:flutter/material.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  void initState() {
    super.initState();
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
            _buildPriceSummary(orderDoc, snapshot),
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
              Text(
                "Estimated Price: ₱${estimatedPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 14),
              ),
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
    String marketId = await _getMarketIdFromName(marketName);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(marketId)
          .collection('Products')
          .get();

      List<Map<String, dynamic>> products =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      return products;
    } catch (e) {
      print('Error fetching market products: $e');
      return [];
    }
  }

  // Helper function to get marketId from marketName
  Future<String> _getMarketIdFromName(String marketName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .where('Market Name', isEqualTo: marketName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        print('No market found with name: $marketName');
        return '';
      }
    } catch (e) {
      print('Error fetching market ID: $e');
      return '';
    }
  }

  // Calculate the estimated price for an item based on the selected market
  Future<double> getEstimatedPrice(
      Map<String, dynamic> itemData, String marketName) async {
    List<Map<String, dynamic>> marketProducts =
        await fetchMarketProducts(marketName);

    for (var product in marketProducts) {
      if (product['Product Name'] == itemData['Name']) {
        if (product['SRPrice'] is int) {
          return (product['SRPrice'] as int).toDouble();
        } else {
          return product['SRPrice'] as double;
        }
      }
    }

    return 0.0;
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

  // Fixed _takeOrder method
  Future<void> _takeOrder() async {
    try {
      // First, get the order document
      DocumentSnapshot orderDoc = await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .get();

      // Update the order with rider information
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .update({
        'isTaken': true,
        'riderId': globalUID,
      });

      // Get the consumer ID from the order
      String consumerId = orderDoc['userId'];

      // Get the rider's document
      DocumentSnapshot riderDoc = await FirebaseFirestore.instance
          .collection('Rider')
          .doc(globalUID)
          .get();

      // Get the consumer's document using the ID from the order
      DocumentSnapshot consumerDoc = await FirebaseFirestore.instance
          .collection('Consumer')
          .doc(consumerId)
          .get();

      // Extract names, using null-coalescing operator for safety
      String riderName = riderDoc.get('First Name') ?? 'Rider';
      String consumerName = consumerDoc.get('First Name') ?? 'Customer';

      // Create or get existing chat
      final chatService = ChatService();
      String? chatId =
          await chatService.getExistingChat(consumerId, globalUID!);

      chatId ??= await chatService.createChat(consumerId, globalUID!);

      // Send welcome message
      String message =
          "Hi $consumerName,\n\nThis is $riderName, your personal shopper at Momo! I'm here to help you with your order. 😊\n\nPlease feel free to send me any questions or special requests you may have. I'll do my best to assist you.";

      await chatService.sendMessage(chatId, message);

      // Navigate to next page
      if (mounted) {
        Navigator.pushNamed(context, '/riderOrderConfirmationPage',
            arguments: widget.orderId);
      }
    } catch (e) {
      print('Error taking order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to take order. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
          onPressed: _takeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3DBC96), // Change the button color
            foregroundColor: Colors.white, // Change the font color
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text("Take This Order"),
        ),
      ),
    );
  }
}
