import 'package:flutter/material.dart';
import 'completeprofileconsumer.dart';

class VerificationConsumer extends StatefulWidget {
  const VerificationConsumer({super.key});

  @override
  State<VerificationConsumer> createState() => _VerificationConsumerState();
}
  
class _VerificationConsumerState extends State<VerificationConsumer> {
  final _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  final _errorBorders = [
    false,
    false,
    false,
    false,
  ];

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Verify Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            const Center(
              child: Text(
                'Please enter the 4-digit code sent to your email address.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 4; i++)
                  Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _errorBorders[i] ? Colors.red : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              !RegExp(r'^[0-9]+$').hasMatch(value)) {
                            setState(() {
                              _errorBorders[i] = true;
                            });
                          } else {
                            setState(() {
                              _errorBorders[i] = false;
                            });
                          }
                          if (value.length == 1) {
                            if (i < 3) {
                              _focusNodes[i + 1].requestFocus();
                            }
                          } else if (value.isEmpty) {
                            if (i > 0) {
                              _focusNodes[i - 1].requestFocus();
                            }
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32.0),
            const Center(
              child: Text(
                "Didn't receive OTP?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Center(
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.green),
                onPressed: () {
                  // TODO: Implement resend code logic
                },
                child: const Text(
                  'Resend Code',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  textStyle: const TextStyle(fontSize: 30, color: Colors.white),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompleteProfileConsumer(),
                    ),
                  );
                },
                child: const Text('Verify'),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
