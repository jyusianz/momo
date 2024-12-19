import 'package:flutter/material.dart';
import 'package:food/firebase/firebase_auth_service.dart';

class Signup_rider extends StatefulWidget {
  const Signup_rider({super.key});

  @override
  State<Signup_rider> createState() => _Signup_riderState();
}

class _Signup_riderState extends State<Signup_rider> {
  bool _agreeToTerms = false;
  final FirebaseAuthService _service = FirebaseAuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms & Conditions'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to Momo! These terms and conditions outline the rules and regulations for the use of Momo, a mobile application developed and operated by Khael Inc.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'By accessing this mobile application, we assume you accept these terms and conditions. Do not continue to use Momo if you do not agree to all of the terms and conditions stated on this page.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Cookies',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'We employ the use of cookies. By accessing Momo, you agree to use cookies in agreement with Momo\'s Privacy Policy.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'License',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Unless otherwise stated, Momo and/or its licensors own the intellectual property rights for all material on Momo. All intellectual property rights are reserved. You may access this from Momo for your own personal use subjected to restrictions set in these terms and conditions.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Restrictions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You are specifically restricted from all of the following:\n- publishing any Momo material in any other media;\n- selling, sublicensing and/or otherwise commercializing any Momo material.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _agreeToTerms = true;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Agree'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fill your information below or register with your social account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 50),
              // First Name
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              // Last Name
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  suffixIcon: Padding(
                    padding:
                        const EdgeInsets.all(8.0), // Adjust padding as needed
                    child: Image.asset(
                      'Momo_images/Invisible.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              // Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value!;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: _showTermsAndConditions,
                    child: const Text(
                      'Agree to Terms & Conditions',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Sign Up Button
              ElevatedButton(
                onPressed: () async {
                  final String emailString = _emailController.text.trim();
                  final String passwordString = _passwordController.text.trim();

                  await _service.registerCredential(
                      emailString, passwordString);
                  Navigator.pushNamed(context, '/verificationRider');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 20),
              // Or sign up with
              const Text(
                '---------- Or sign up with---------',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              // Social Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Facebook Icon
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue,
                    child: Image.asset(
                      'Momo_images/Facebook.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Google Icon
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'Momo_images/Google.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signin_rider');
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
