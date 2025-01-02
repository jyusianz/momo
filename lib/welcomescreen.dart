// import 'package:flutter/material.dart';
// import 'package:food/utils/constants.dart';

// class Home extends StatelessWidget {
//   const Home({Key? key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Container(
//           child: const Text(
//             'MOMO',
//             style: TextStyle(
//                 color: primaryColor, fontSize: 64),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color.fromARGB(255, 245, 245, 245),
              Color.fromARGB(255, 238, 238, 238)
            ],
            center: Alignment(-0.6, -0.6),
            radius: 1.5,
          ),
        ),
        child: Stack(
          children: [
            const Align(
              alignment: Alignment(-1.5, -1.5),
              child: CircleAvatar(
                radius: 150,
                backgroundColor: Color(0xFF1B917D),
              ),
            ),
            const Align(
              alignment: Alignment(1, -1),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color.fromARGB(255, 32, 179, 147),
              ),
            ),
            const Align(
              alignment: Alignment(1.5, 1.5),
              child: CircleAvatar(
                radius: 170,
                backgroundColor: Color.fromARGB(255, 32, 179, 147),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/user');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                    ),
                    child: Image.asset(
                      'Momo_images/Momo logo.png',
                      width: 200,
                      height: 100,
                    ),
                  ),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Online Grocery App',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
