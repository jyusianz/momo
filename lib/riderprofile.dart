import 'package:flutter/material.dart';

class Riderprofile extends StatefulWidget {
  const Riderprofile({super.key});

  @override
  State<Riderprofile> createState() => _RiderprofileState();
}

class _RiderprofileState extends State<Riderprofile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset('Momo_images/back.png', height: 30, width: 30),
          ),
        ),
        title: const Text(
          '                       Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                  ),
                  Image.asset('Momo_images/profile.png', height: 60, width: 60),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Rider 12345',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  buildListTile(
                    leadingImage: 'Momo_images/User.png',
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.pushNamed(context, '/editprofilerider');
                    },
                  ),
                  buildListTile(
                    leadingImage: 'Momo_images/Place Marker.png',
                    title: 'Manage Address',
                    onTap: () {
                      Navigator.pushNamed(context, '/manageaddressrider');
                    },
                  ),
                  buildListTile(
                    leadingImage: 'Momo_images/Card Payment.png',
                    title: 'Payment Methods',
                    onTap: () {
                      Navigator.pushNamed(context, '/paymentmethodrider');
                    },
                  ),
                  buildListTile(
                    leadingImage: 'Momo_images/Settings.png',
                    title: 'Settings',
                    onTap: () {
                      Navigator.pushNamed(context, '/settingsrider');
                    },
                  ),
                  buildListTile(
                    leadingImage: 'Momo_images/Help.png',
                    title: 'Help Center',
                    onTap: () {
                      Navigator.pushNamed(context, '/helpcenterrider');
                    },
                  ),
                  buildListTile(
                    leadingImage: 'Momo_images/Settings.png',
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pushNamed(context, '/privacypolicyrider');
                    },
                  ),
                ],
              ),
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
              Navigator.pushNamed(context, '/chatrider');
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

  Widget buildListTile({
    required String leadingImage,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Image.asset(leadingImage,
          width: 24,
          height: 24), // Set width and height to 24x24 pixels for consistency
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: Image.asset('Momo_images/fluent-arrow.png',
          width: 16, height: 16), // Set trailing arrow to a smaller size
      onTap: onTap,
    );
  }
}
