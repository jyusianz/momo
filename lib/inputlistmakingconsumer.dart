import 'package:flutter/material.dart';

class Inputlistmakingconsumer extends StatelessWidget {
  const Inputlistmakingconsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color.fromARGB(255, 143, 236, 201),
                Color.fromARGB(255, 54, 212, 152),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
