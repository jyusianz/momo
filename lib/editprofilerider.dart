import 'package:flutter/material.dart';
import 'package:food/firebase/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Editprofilerider extends StatefulWidget {
  const Editprofilerider({super.key});

  @override
  State<Editprofilerider> createState() => _EditprofileriderState();
}

class _EditprofileriderState extends State<Editprofilerider> {
  String _username = 'User';
  String firstName = 'User';
  String lastName = 'User';
  String email = 'user@gmail.com';
  String phoneNumber = '+630000000000';
  String gender = 'Female';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (globalUID != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Rider')
            .doc(globalUID!)
            .get();

        if (userDoc.exists) {
          setState(() {
            _username = userDoc['User Name'];
            firstName = userDoc['First Name'];
            lastName = userDoc['Last Name'];
            email = userDoc['email'];
            phoneNumber = userDoc['Mobile Number'];
            gender = userDoc['Gender'];
          });
        } else {
          print('User document not found');
        }
      } catch (e) {
        print('Error fetching user details: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fecthing user details.')),
        );
      }
    }
  }

  Future<void> saveEditprofile(uname, fname, lname, mnumber) async {
    try {
      await FirebaseFirestore.instance
          .collection('Rider')
          .doc(globalUID)
          .update({
        'User Name': uname,
        'First Name': fname,
        'Last Name': lname,
        'Mobile Number': '0' + mnumber,
        'Gender': gender, // Update the gender in Firestore
      });
      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _usernameController =
        TextEditingController(text: _username);
    final TextEditingController _phoneNumberController =
        TextEditingController(text: phoneNumber.substring(1, 11));
    final TextEditingController _LastNameController =
        TextEditingController(text: lastName);
    final TextEditingController _FirstNameController =
        TextEditingController(text: firstName);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        elevation: 0,
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
      resizeToAvoidBottomInset: true, // Ensures screen adjusts for keyboard
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child: Image.asset(
                        'Momo_images/Account.png',
                        width: 80,
                        height: 60,
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
              const SizedBox(height: 20),
              const Text(
                'Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _FirstNameController,
                decoration: InputDecoration(
                  hintText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _LastNameController,
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: email,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                enabled: false,
              ),
              const SizedBox(height: 20),
              const Text(
                'Phone Number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
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
              const SizedBox(height: 20),
              const Text(
                'Gender',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
                value: gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) {
                  setState(() {
                    gender = value.toString();
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    saveEditprofile(
                      _usernameController.text.trim(),
                      _FirstNameController.text.trim(),
                      _LastNameController.text.trim(),
                      _phoneNumberController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF21A490),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
