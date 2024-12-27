import 'package:flutter/material.dart';

class Orderriderupdate extends StatefulWidget {
  const Orderriderupdate({super.key});

  @override
  State<Orderriderupdate> createState() => _OrderriderupdateState();
}

class _OrderriderupdateState extends State<Orderriderupdate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 241, 243, 241),
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
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 16),
            // List of OrderItems
            Column(
              children: [
                const OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Eggs',
                  description:
                      '1 tray of 1 dozen eggs\nWeight:            Volume:',
                  price: 'P 250.00',
                  quantity: 1,
                ),
                const OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Eggs',
                  description:
                      '1 tray of 1 dozen eggs\nWeight:            Volume:',
                  price: 'P 250.00',
                  quantity: 1,
                ),
                const OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Eggs',
                  description:
                      '1 tray of 1 dozen eggs\nWeight:            Volume:',
                  price: 'P 250.00',
                  quantity: 1,
                ),
                const OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Eggs',
                  description:
                      '1 tray of 1 dozen eggs\nWeight:            Volume:',
                  price: 'P 250.00',
                  quantity: 1,
                ),
                const OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Eggs',
                  description:
                      '1 tray of 1 dozen eggs\nWeight:            Volume:',
                  price: 'P 250.00',
                  quantity: 1,
                ),
                const OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Eggs',
                  description:
                      '1 tray of 1 dozen eggs\nWeight:            Volume:',
                  price: 'P 250.00',
                  quantity: 1,
                ),
                const OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Eggs',
                  description:
                      '1 tray of 1 dozen eggs\nWeight:            Volume:',
                  price: 'P 250.00',
                  quantity: 1,
                ),
                const OrderItem(
                  imageUrl: 'Momo_images/egg.png',
                  name: 'Eggs',
                  description:
                      '1 tray of 1 dozen eggs\nWeight:            Volume:',
                  price: 'P 250.00',
                  quantity: 1,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/orderrecieptrider');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Shopping Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderItem extends StatefulWidget {
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
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  final _formKey = GlobalKey<FormState>();
  String _price = '';
  final String _weight = '';
  final String _volume = '';
  int _quantity = 1;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _price = widget.price;
    _quantity = widget.quantity;
  }

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
              widget.imageUrl,
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
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _isEditing
                      ? Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: _price,
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a price';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _price = value!,
                              ),
                              TextFormField(
                                initialValue: _weight,
                                decoration: const InputDecoration(
                                  labelText: 'Weight',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              TextFormField(
                                initialValue: _volume,
                                decoration: const InputDecoration(
                                  labelText: 'Volume',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: _quantity.toString(),
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            int.parse(value) <= 0) {
                                          return 'Please enter a valid quantity';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) =>
                                          _quantity = int.parse(value!),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        setState(() {
                                          _isEditing = false;
                                        });
                                      }
                                    },
                                    child: const Text('Update'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Text(widget.description),
                            Row(
                              children: [
                                Text('x${widget.quantity}'),
                                const SizedBox(width: 16),
                                Text(widget.price),
                              ],
                            ),
                          ],
                        ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _isEditing
                    ? const SizedBox()
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        child: const Text('Edit'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
