import 'package:flutter/material.dart';
import 'package:Momo/firebase/firebase_auth_service.dart';

class Signin_consumer extends StatefulWidget {
  const Signin_consumer({super.key});

  @override
  State<Signin_consumer> createState() => _Signin_consumerState();
}

class _Signin_consumerState extends State<Signin_consumer> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _service = FirebaseAuthService();

  // Add this method to the _Signin_consumerState class
  Future<void> signIn() async {
    print('\n=== Starting SignIn Process ===');

    final emailString = _emailController.text.trim();
    final passwordString = _passwordController.text.trim();

    print('📝 Login attempt with:');
    print('- Email: $emailString');

    try {
      print('\n🔄 Attempting to verify credentials with Firebase Auth...');
      final user = await _service.verifyCredential(emailString, passwordString);

      if (user != null) {
        print('✅ Login Successful!');
        print('📌 User ID: $globalUID');
        print('📧 Email: $emailString');
        print('=== End of SignIn Process ===\n');

        // Navigate to the home screen if login is successful
        Navigator.pushNamed(context, '/consumerHome');
      } else {
        print('❌ Login Failed: Invalid credentials');
        print('=== End of SignIn Process with Error ===\n');

        // Show an error message if login fails
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    } catch (e) {
      print('\n❌ SignIn Error:');
      print('- Error Type: ${e.runtimeType}');
      print('- Error Message: $e');
      print('=== End of SignIn Process with Error ===\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
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
              const SizedBox(height: 5),
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Hi welcome back, youve been missed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 60),
              // First Name
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
              const SizedBox(height: 8),
              // Last Name

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
              // Forgot Password
              TextButton(
                onPressed: () async {
                  final emailString = _emailController.text.trim();
                  final passwordString = _passwordController.text.trim();

                  final user = await _service.verifyCredential(
                      emailString, passwordString);
                  user != null
                      ? {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen()))
                        }
                      : {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Invalid credentials'),
                              duration: const Duration(
                                  seconds:
                                      3), // Duration the Snackbar will be shown
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  // Code to execute when the action is pressed
                                },
                              ),
                            ),
                          )
                        };
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF12958C),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Sign Up Button
              // Modify the ElevatedButton's onPressed callback to use the new signIn method
              ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF12958C),
                  foregroundColor: const Color(0xFFFFFFFF),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Sign In'),
              ),

              const SizedBox(height: 20),
              // Or sign up with
              const Text(
                '---------- Or sign in with---------',
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
                      width: 50,
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
                      width: 50,
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
                      Navigator.pushNamed(context, '/signup_consumer');
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color(0xFF12958C),
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your email address to reset your password.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement password reset logic here
                // For example, send a reset email
              },
              child: const Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}
