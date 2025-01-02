import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/firebase/firebase_auth_service.dart';
import 'package:food/orderConfirmationPage3.dart';
import 'package:intl/intl.dart';

class Listconsumer extends StatefulWidget {
  const Listconsumer({super.key});

  @override
  State<Listconsumer> createState() => _ListconsumerState();
}

class _ListconsumerState extends State<Listconsumer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevents the default back button
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '\n', // Add an empty line
              ),
              TextSpan(
                text: '\tMy Orders', // Add tab and the actual text
                style: TextStyle(
                  fontSize: 30, // Adjust font size
                  fontWeight: FontWeight.bold, // Make it bold
                  color: Colors.black, // Optional: change text color
                ),
              ),
            ],
          ),
          textAlign: TextAlign.start, // Optional: Align text to the start
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Ongoing Orders
          _buildOngoingOrdersStream(),
          // Order History
          _buildOrderHistoryStream(), // Replace with stream builder
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
              Navigator.pushNamed(
                context,
                '/chatListScreen',
              );
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
}

// Build the stream of ongoing orders from Firestore
Widget _buildOngoingOrdersStream() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Orders')
        .where('isPlaced', isEqualTo: true)
        .where('isDelivered', isEqualTo: false)
        .where('userId', isEqualTo: globalUID)
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
          child: Text("No ongoing orders."),
        );
      }

      return ListView(
        children: snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

          return OrderCard(
            orderNumber: document.id,
            date: DateFormat('yyyy-MM-dd HH:mm')
                .format(data['orderedAt'].toDate()),
            items: '${data['itemCount']} items',
            price: data['estTotal'].toStringAsFixed(2),
            onTap: () {
              // Navigate to OrderConfirmationPage3 and pass the order ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderConfirmationPage3(orderId: document.id),
                ),
              );
            },
          );
        }).toList(),
      );
    },
  );
}

// Build the stream of order history from Firestore
Widget _buildOrderHistoryStream() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Orders')
        .where('isPlaced', isEqualTo: true)
        .where('isDelivered', isEqualTo: true)
        .where('userId', isEqualTo: globalUID)
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
          child: Text("No completed orders."),
        );
      }

      return ListView(
        children: snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

          return OrderCard(
            orderNumber: document.id,
            date: DateFormat('yyyy-MM-dd HH:mm')
                .format(data['orderedAt'].toDate()),
            items: '${data['itemCount']} items',
            price: data['estTotal'].toStringAsFixed(2),
            onTap: () {
              // Navigate to OrderConfirmationPage3 and pass the order ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderConfirmationPage3(orderId: document.id),
                ),
              );
            },
          );
        }).toList(),
      );
    },
  );
}

class OrderCard extends StatelessWidget {
  final VoidCallback onTap; // Make sure this is defined
  final String orderNumber;
  final String date;
  final String items;
  final String price;

  const OrderCard({
    super.key,
    required this.onTap,
    required this.orderNumber,
    required this.date,
    required this.items,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order No. $orderNumber',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱$price',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
