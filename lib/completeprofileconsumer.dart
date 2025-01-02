import 'package:flutter/material.dart';
import 'firebase/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfileConsumer extends StatefulWidget {
  const CompleteProfileConsumer({super.key});

  @override
  _CompleteProfileConsumerState createState() =>
      _CompleteProfileConsumerState();
}

class _CompleteProfileConsumerState extends State<CompleteProfileConsumer> {
  String _selectedGender = 'Male';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

// Function to show the image upload dialog
  void _showImageUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  // Pick an image from gallery
                  final XFile? image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    await FirebaseFirestore.instance
                        .collection('Consumer')
                        .doc(globalUID)
                        .update({'avatar': image});
                  }
                },
                child: Text('Choose from Gallery'),
              ),
              TextButton(
                onPressed: () async {
                  // Pick an image from camera
                  final XFile? image =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (image != null) {
                    // TODO: Handle image upload to Firebase Storage
                  }
                },
                child: Text('Take a Photo'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Image.asset(
            'Momo_images/back.png',
            width: 30,
            height: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Complete Your Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    // Make the CircleAvatar clickable
                    onTap: () {
                      _showImageUploadDialog(context);
                    },
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child: Image.asset(
                        'Momo_images/Account.png',
                        width: 80,
                        height: 60,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF50C26F),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      'Momo_images/Photo Gallery.png',
                      width: 20,
                      height: 65,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Username',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter your username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mobileNumberController,
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          '+63',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Gender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Image.asset(
                  'Momo_images/Expand Arrow.png',
                  width: 30,
                  height: 30,
                ),
              ),
              value: 'Male',
              items: const [
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Male'),
                ),
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value.toString(); // Update selected value
                });
              },
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pushNamed(context, '/consumerHome');
                  final usernameString = _usernameController.text.trim();
                  final mobileNumberString =
                      _mobileNumberController.text.trim();

                  await FirebaseFirestore.instance
                      .collection('Consumer')
                      .doc(globalUID)
                      .update({
                    'User Name': usernameString,
                    'Mobile Number': mobileNumberString,
                    'Gender': _selectedGender,
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  backgroundColor: const Color(0xFF12958C),
                  foregroundColor: const Color(0xFFFFFFFF),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Complete Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
