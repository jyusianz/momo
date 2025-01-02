import 'package:flutter/material.dart';
import 'package:food/firebase/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Consumerprofile extends StatefulWidget {
  const Consumerprofile({super.key});

  @override
  State<Consumerprofile> createState() => _RiderprofileState();
}

class _RiderprofileState extends State<Consumerprofile> {
  String _userName = 'User'; // Default name

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    if (globalUID != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Consumer')
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '\n', // Add an empty line
              ),
              TextSpan(
                text: '\tProfile', // Add tab and the actual text
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
            Center(
              child: Text(
                _userName,
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
                      Navigator.pushNamed(context, '/editprofileconsumer');
                    },
                  ),
                  buildListTile(
                    leadingImage: 'Momo_images/Place Marker.png',
                    title: 'Manage Address',
                    onTap: () {
                      Navigator.pushNamed(context, '/manageaddressconsumer');
                    },
                  ),
                  // comment here
                  buildListTile(
                    leadingImage: 'Momo_images/Settings.png',
                    title: 'Settings',
                    onTap: () {
                      Navigator.pushNamed(context, '/settingsconsumer');
                    },
                  ),
                  buildListTile(
                    leadingImage: 'Momo_images/log-out.png',
                    title: 'Log Out',
                    onTap: () async {
                      try {
                        // Sign out the user
                        await FirebaseAuth.instance.signOut();

                        // Navigate to the login screen or home screen
                        // You might need to replace '/login' with your actual login route
                        Navigator.pushReplacementNamed(context, '/user');
                      } catch (e) {
                        // Handle any errors that occur during sign-out
                        print('Error signing out: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error signing out.')),
                        );
                      }
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
              Navigator.pushNamed(context, '/chatListScreen');
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
