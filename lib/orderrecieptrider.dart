import 'package:flutter/material.dart';

class Orderrecieptrider extends StatefulWidget {
  const Orderrecieptrider({super.key});

  @override
  State<Orderrecieptrider> createState() => _OrderrecieptriderState();
}

class _OrderrecieptriderState extends State<Orderrecieptrider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 241, 243, 241),
        leading: IconButton(
          icon: Image.asset('Momo_images/back.png', height: 30, width: 30),
          onPressed: () {
            Navigator.pushNamed(context, '/riderHome');
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
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Order No. 123456",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "ORDER FORM",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Juan Deck",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Text(
            "    +(63)9123456789",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const Text(
            "    Zone 6, Gumamela Street,",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const Text(
            "    Macanhan Carmen, Cagayan de Oro City",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const Text(
            "    Mis. Or., 9000",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Product List Section
                  for (int i = 0; i < 5; i++)
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/eggs.jpg', // Replace with your image path
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Fresh Eggs",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Quantity: 1",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Price: P 192.50",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Payment Summary Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Merchandise Estimated Subtotal: P 300.00",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Shipping Subtotal: P 50.00",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Transaction Fee: P 10.00",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Total Payment: P 360.00",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Note Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        "Note:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "An overpayment will be returned to the customer upon delivery.",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
