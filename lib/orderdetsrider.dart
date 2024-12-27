import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Orderdetsrider(),
    );
  }
}

class Orderdetsrider extends StatefulWidget {
  const Orderdetsrider({super.key});

  @override
  State<Orderdetsrider> createState() => _OrderdetsriderState();
}

class _OrderdetsriderState extends State<Orderdetsrider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Order Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Image.asset('Momo_images/back.png', height: 30, width: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const OrderDetailsScreen(),
    );
  }
}

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ORDER FROM',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Juan Deck',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('+63 912 345 6789'),
            const Text(
              'Zone 6, Gumamela Street, Macanhan Carmen, Cagayan de Oro City, Mis. Or., 9000',
            ),
            const SizedBox(height: 8),
            const Text(
              'Shop: Gaisano',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Column(
              children: [
                OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Eggs',
                  description:
                      '1 tray of 1 dozen eggs\nWeight:            Volume:',
                  price: 'P 250.00',
                  quantity: 1,
                ),
                OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Butter',
                  description:
                      'Buttercup Margarine\nWeight: 200g    Volume:\n"Keep cold."',
                  price: 'P 250.00',
                  quantity: 2,
                ),
                OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Brown Sugar',
                  description:
                      'Great Value Pure Brown Sugar\nWeight: 1 kilo     Volume:',
                  price: 'P 250.00',
                  quantity: 3,
                ),
                OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'All Purpose Flour',
                  description:
                      'Great Value All Purpose Flour\nWeight: 1 kilo   Volume:',
                  price: 'P 250.00',
                  quantity: 2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Merchandise Estimated Subtotal                        P 1,000.00',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Shipping Subtotal                                                  P 150.00',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Transaction Fee                                                     P 15.00',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Total Payment:                     P 1,165.00',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Paid with GCash',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: const EdgeInsets.all(16),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'Momo_images/check.png',
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Customer's payment will be sent into your account.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/listrider2ongo');
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              textStyle: const TextStyle(fontSize: 20),
                            ),
                            child: const Text('Continue'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Take Order'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final int quantity;

  const OrderItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('x$quantity'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
