import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:food/services/stripe_service.dart';
import 'package:food/orderConfirmationPage3.dart';

class OrderConfirmationPage2 extends StatefulWidget {
  final String orderId;

  const OrderConfirmationPage2({super.key, required this.orderId});

  @override
  State<OrderConfirmationPage2> createState() => _OrderConfirmationPage2State();
}

class _OrderConfirmationPage2State extends State<OrderConfirmationPage2> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController(); // Add address controller
  String? _selectedMarket; // To store the selected market
  List<String> _marketNames = []; // To store the list of available markets
  List<String> _addressSuggestions = []; // Add this line
  //String? _selectedAddress; // Add this line

  String? _firstName;
  String? _lastName;
  String? _phoneNumber;
  double? _total;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the widget initializes
    _fetchMarketNames(); // Fetch market names when the widget initializes
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .get();

      setState(() {
        _firstName = orderDoc['firstName'];
        _lastName = orderDoc['lastName'];
        _phoneNumber = orderDoc['mobileNumber'];
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Fetch market names from Firestore
  Future<void> _fetchMarketNames() async {
    try {
      final marketsSnapshot = await FirebaseFirestore.instance
          .collection('Markets') // Fetch from 'Markets' collection
          .get();

      setState(() {
        _marketNames = marketsSnapshot.docs
            .map(
                (doc) => doc['Market Name'] as String) // Get 'marketName' field
            .toList();
      });
    } catch (e) {
      print('Error fetching market names: $e');
    }
  }

// Function to fetch address suggestions using OpenCage Data
  Future<List<String>> _fetchAddressSuggestions(String input) async {
    final request =
        'https://api.opencagedata.com/geocode/v1/json?q=$input&key=8477206bd8654ad38355a0d819079eb1&limit=5'; // Replace YOUR_API_KEY
    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((r) => r['formatted'] as String).toList();
    } else {
      throw Exception('Failed to load address suggestions');
    }
  }

  // Function to show address suggestions in a DropdownButton
  void showSuggestions(BuildContext context, List<String> suggestions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Address Suggestions'),
          content: SizedBox(
            width: double.maxFinite,
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Address',
                border: OutlineInputBorder(),
              ),
              items: suggestions.map((suggestion) {
                return DropdownMenuItem(
                  value: suggestion,
                  child: Text(suggestion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _addressController.text = value!;
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Build the AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text("Confirm Order"),
      leading: IconButton(
        icon: Image.asset('Momo_images/back.png'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

// Build the body of the Scaffold
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display the name with edit button
            Card(
              child: ListTile(
                title: Text(
                  '${_firstName ?? ''} ${_lastName ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditNameDialog();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            // Display the phone number with edit button
            Card(
              child: ListTile(
                title: Text(
                  _phoneNumber ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditPhoneNumberDialog();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            // Input field for delivery address with autocompletion
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (input) async {
                        // Fetch address suggestions when the user types
                        if (input.length > 3) {
                          // Start fetching after at least 3 characters
                          final suggestions =
                              await _fetchAddressSuggestions(input);
                          // Update the suggestions state
                          setState(() {
                            _addressSuggestions = suggestions;
                          });
                        } else {
                          setState(() {
                            _addressSuggestions = [];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    // Market selection dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedMarket,
                      decoration: const InputDecoration(
                        labelText: 'Select Market',
                        border: OutlineInputBorder(),
                      ),
                      items: _marketNames.map((market) {
                        return DropdownMenuItem(
                          value: market,
                          child: Text(market),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMarket = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24.0),

                    // Display the items with estimated prices
                    _buildItemsList(),

                    const SizedBox(height: 24.0),

                    // Display the subtotal, delivery fee, service fee, and total
                    _buildPriceSummary(), // New function to build the price summary
                  ],
                ),
                // Positioned widget for the suggestions dropdown
                if (_addressSuggestions.isNotEmpty)
                  Positioned(
                    top: 80, // Adjust the top position as needed
                    left: 0,
                    right: 0,
                    child: Container(
                      // Add a Container with a background color
                      color: Colors.white, // Set the background color to white
                      height: 200,
                      child: ListView.builder(
                        itemCount: _addressSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _addressSuggestions[index];
                          return ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              setState(() {
                                _addressController.text = suggestion;
                                _addressSuggestions = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Modified _buildPriceSummary() to add info buttons
  Widget _buildPriceSummary() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .collection('Items')
          .snapshots(),
      builder: (context, snapshot) {
        double subtotal = 0;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var document in snapshot.data!.docs) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            subtotal += data['totalPrice'] ?? 0;
          }
        }

        double deliveryFee = 60;
        double serviceFee = calculateServiceFee(subtotal);
        double total = subtotal + deliveryFee + serviceFee;

        // Update the order document with the new total and selected values
        _updateOrderDetails(total);

        _total = total;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      },
    );
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

// Add this new method to update order details
  Future<void> _updateOrderDetails(double total) async {
    try {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .update({
        'deliveryAddress': _addressController.text,
        'market': _selectedMarket,
        'estTotal': total,
      });
    } catch (e) {
      print('Error updating order details: $e');
    }
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

// Build the list of items with estimated prices
  Widget _buildItemsList() {
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

        if (_selectedMarket == null) {
          // If no market is selected, show a message or placeholder
          return const Center(
            child: Text("Please select a market to see estimated prices."),
          );
        }

        return FutureBuilder<List<Widget>>(
          future: _buildItemTiles(snapshot.data!.docs, _selectedMarket!),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (futureSnapshot.hasError) {
              return Text('Error: ${futureSnapshot.error}');
            } else {
              return Column(children: futureSnapshot.data!);
            }
          },
        );
      },
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
      // Update the srPrice and totalPrice in the Firestore document
      await document.reference.update({
        'srPrice': estimatedPrice,
        'totalPrice': itemTotal,
      });
      tiles.add(
        Card(
          child: ListTile(
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
                  "Estimated Price: \$${estimatedPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 14),
                ),
                // Display total price for this item (totalPrice)
                Text(
                  "Item Total: \$${itemTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return tiles;
  }

  // Calculate and display the estimated total price
  /*Widget _buildEstimatedTotalPrice() {
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

        if (_selectedMarket == null) {
          // If no market is selected, show a message or return an empty Container
          return const SizedBox();
        }

        return FutureBuilder<double>(
          future: _calculateTotalPrice(snapshot.data!.docs, _selectedMarket!),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (futureSnapshot.hasError) {
              return Text('Error: ${futureSnapshot.error}');
            } else {
              double totalPrice = futureSnapshot.data ?? 0;
              return Text(
                "Estimated Total: \$${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          },
        );
      },
    );
  }*/

  /*
  // Helper function to calculate total price asynchronously
  Future<double> _calculateTotalPrice(
      List<QueryDocumentSnapshot> docs, String marketName) async {
    double totalPrice = 0;
    for (var document in docs) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      totalPrice += await getEstimatedPrice(
          data, marketName); // Await getEstimatedPrice with both arguments
    }
    return totalPrice;
  }*/

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

  // Show the dialog to edit the name
  void _showEditNameDialog() {
    _firstNameController.text = _firstName ?? '';
    _lastNameController.text = _lastName ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Name"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("First Name", _firstNameController),
              const SizedBox(height: 16.0),
              _buildTextField("Last Name", _lastNameController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _updateName();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Show the dialog to edit the phone number
  void _showEditPhoneNumberDialog() {
    _phoneNumberController.text = _phoneNumber ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Phone Number"),
          content: _buildTextField("Phone Number", _phoneNumberController),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _updatePhoneNumber();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Update the name in the order document
  Future<void> _updateName() async {
    try {
      final orderRef =
          FirebaseFirestore.instance.collection('Orders').doc(widget.orderId);

      await orderRef.update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
      });

      setState(() {
        _firstName = _firstNameController.text.trim();
        _lastName = _lastNameController.text.trim();
      });

      print("Name updated successfully.");
    } catch (e) {
      print("Error updating name: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating name.")),
      );
    }
  }

  // Update the phone number in the order document
  Future<void> _updatePhoneNumber() async {
    try {
      final orderRef =
          FirebaseFirestore.instance.collection('Orders').doc(widget.orderId);

      await orderRef.update({
        'mobileNumber': _phoneNumberController.text.trim(),
      });

      setState(() {
        _phoneNumber = _phoneNumberController.text.trim();
      });

      print("Phone number updated successfully.");
    } catch (e) {
      print("Error updating phone number: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating phone number.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: Container(
        width: double.infinity, // Make the button the same width as the screen
        color: Colors.green, // Set the button color to green
        child: TextButton(
          onPressed: () async {
            if (_addressController.text.isEmpty || _selectedMarket == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Please fill in all required fields.")),
              );
              return;
            }

            final paymentSuccess =
                await StripeService.instance.makePayment(_total!);
            if (paymentSuccess) {
              print("Payment successful");

              await FirebaseFirestore.instance
                  .collection('Orders')
                  .doc(widget.orderId)
                  .update({'isPlaced': true});

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderConfirmationPage3(orderId: widget.orderId),
                ),
              );
            } else {
              print('Payment failed.');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Payment failed. Please try again.")),
              );
            }

            /*
            //bool paymentSuccess = false;

            // Payment Process
            //try {
            //print("Initiating payment...");
            await StripeService.instance.makePayment(_total!);
            //paymentSuccess = true;
            //print("Payment successful");
            /*} catch (e) {
              print('Payment error: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Payment failed. Please try again.")),
              );
              return;
            }*/

            // Database Update
            //if (paymentSuccess) {
            //try {
            //print("Updating Firestore...");
            await FirebaseFirestore.instance
                .collection('Orders')
                .doc(widget.orderId)
                .update({'isPlaced': true});
            //print("Firestore updated");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderConfirmationPage3(orderId: widget.orderId),
              ),
            );
            /* } catch (e) {
              print('Firestore update failed: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to update database.")),
              );
            }*/
            //}
            */
          },
          child: const Text(
            "Pay Now",
            style: TextStyle(
              color: Colors.black, // Set font color to black
              fontWeight: FontWeight.w500, // Medium weight
            ),
          ),
        ),
      ),
    );
  }
}
