import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food/firebase/firebase_auth_service.dart';
import 'package:food/orderdetails.dart';
import 'package:intl/intl.dart';
//import 'package:food/orderConfirmationPage3.dart';

class RiderHome extends StatefulWidget {
  const RiderHome({super.key});
  @override
  State<RiderHome> createState() => _RiderHomeState();
}

class _RiderHomeState extends State<RiderHome> {
  String _userName = 'User'; // Default name

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
            .collection('Rider')
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
              padding: EdgeInsets.fromLTRB(32, 1, 1, 32),
              child: Text(
                '"Are you ready to work? Choose an order below."',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const Divider(),
            // StreamBuilder to fetch and display orders
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Orders')
                  .where('isPlaced', isEqualTo: true)
                  .where('isTaken', isEqualTo: false)
                  .where('isCompleted', isEqualTo: false)
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
                    child: Text("No orders available."),
                  );
                }

                return ListView(
                  shrinkWrap: true, // Important for ListView inside Column
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;

                    return OrderCard(
                      orderNumber: document.id,
                      date: DateFormat('yyyy-MM-dd HH:mm')
                          .format((data['orderedAt'] as Timestamp).toDate()),
                      items: '${data['itemCount']} items',
                      price: data['estTotal'].toStringAsFixed(2),
                      onTap: () {
                        // Navigate to OrderConfirmationPage3 and pass the order ID
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsPage(orderId: document.id),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/riderHome');
            },
            child: Image.asset('Momo_images/home.png'),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/listrider');
            },
            child: Image.asset('Momo_images/orders.png'),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/chatListScreen');
            },
            child: Image.asset('Momo_images/chat.png'),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/riderprofile');
            },
            child: Image.asset('Momo_images/profile.png'),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String orderNumber;
  final String date;
  final String items;
  final String price;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.date,
    required this.items,
    required this.price,
    required this.onTap,
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
                      'P $price',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3DBC96),
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
