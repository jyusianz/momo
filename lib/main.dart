import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food/firebase_options.dart';
import 'package:food/showlistconsumer.dart';
import 'package:food/utils/rider.dart';
import 'package:food/signup_rider.dart';
import 'package:food/signin_rider.dart';
import 'package:food/verificationRider.dart';
import 'package:food/completeprofileRider.dart';
import 'package:food/riderHome.dart';
import 'package:food/listrider.dart';
import 'package:food/chatrider.dart';
import 'package:food/riderprofile.dart';
import 'package:food/orderdetsrider.dart';
import 'package:food/editprofilerider.dart';
import 'package:food/manageaddressrider.dart';
import 'package:food/paymentmethodrider.dart';
import 'package:food/settingsrider.dart';
import 'package:food/helpcenterrider.dart';
import 'package:food/privacypolicyrider.dart';
import 'package:food/messengerrider.dart';
import 'package:food/consumer.dart';
import 'package:food/welcomeScreen.dart';
import 'package:food/signup_consumer.dart';
import 'package:food/signin_consumer.dart';
import 'package:food/verificationConsumer.dart';
import 'package:food/completeprofileconsumer.dart';
import 'package:food/consumerHome.dart';
import 'package:food/listconsumer.dart';
import 'package:food/chatconsumer.dart';
import 'package:food/consumerprofile.dart';
import 'package:food/editprofileconsumer.dart';
import 'package:food/manageaddressconsumer.dart';
import 'package:food/paymentmethodconsumer.dart';
import 'package:food/settingsconsumer.dart';
import 'package:food/helpcenterconsumer.dart';
import 'package:food/privacypolicyconsumer.dart';
import 'package:food/inputlistconsumer.dart';
import 'package:food/orderlistrequestconsumer.dart';
import 'package:food/messengerconsumer.dart';
import 'package:food/orderrequestconsumer.dart';
import 'package:food/redirectingtogcash.dart';
import 'package:food/waitingconsumer.dart';
import 'package:food/estarrivalconsumer.dart';
import 'package:food/Listrider2ongo.dart';
import 'package:food/orderriderupdate.dart';
import 'package:food/orderrecieptrider.dart';
import 'package:food/folderpage.dart';
import 'utils/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase could not initalize');
  }
  runApp(const MomoApp());
}

class MomoApp extends StatelessWidget {
  const MomoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momo App',
      debugShowCheckedModeBanner: false,
      home: const Home(),
      routes: {
        '/user': (context) => const User(),
        '/rider': (context) => const Rider(),
        '/consumer': (context) => const Consumer(),
        '/signup_rider': (context) => const Signup_rider(),
        '/signup_consumer': (context) => const SignupConsumer(),
        '/signin_rider': (context) => const Signin_rider(),
        '/signin_consumer': (context) => const Signin_consumer(),
        '/verificationRider': (context) => const VerificationRider(),
        '/verificationConsumer': (context) =>
            const VerificationConsumer(), // Placeholder const VerificationConsumer(),
        '/completeprofileRider': (context) => const CompleteprofileRider(),
        '/riderHome': (context) => const RiderHome(),
        '/listrider': (context) => const Listrider(),
        '/chatrider': (context) => const Chatrider(),
        '/riderprofile': (context) => const Riderprofile(),
        '/orderdetsrider': (context) => const Orderdetsrider(),
        '/completeprofileconsumer': (context) =>
            const CompleteProfileConsumer(), // Placeholder
        '/editprofilerider': (context) => const Editprofilerider(),
        '/manageaddressrider': (context) => const Manageaddressrider(),
        '/paymentmethodrider': (context) => const Paymentmethodrider(),
        '/settingsrider': (context) => const Settingsrider(),
        '/helpcenterrider': (context) => const Helpcenterrider(),
        '/privacypolicyrider': (context) => const Privacypolicyrider(),
        '/messengerrider': (context) => const Messengerrider(),
        '/consumerHome': (context) => const ConsumerHome(),
        '/listconsumer': (context) => const Listconsumer(),
        '/chatconsumer': (context) => const Chatconsumer(),
        '/consumerprofile': (context) => const Consumerprofile(),
        '/editprofileconsumer': (context) => const Editprofileconsumer(),
        '/manageaddressconsumer': (context) => const Manageaddressconsumer(),
        '/paymentmethodconsumer': (context) => const Paymentmethodconsumer(),
        '/settingsconsumer': (context) => const Settingsconsumer(),
        '/helpcenterconsumer': (context) => const Helpcenterconsumer(),
        '/privacypolicyconsumer': (context) => const Privacypolicyconsumer(),
        '/inputlistconsumer': (context) => const Inputlistconsumer(),
        '/orderlistrequestconsumer': (context) =>
            const Orderlistrequestconsumer(),
        '/messengerconsumer': (context) => const Messengerconsumer(),
        '/orderrequestconsumer': (context) => const Orderrequestconsumer(),
        '/redirectingtogcash': (context) => const Redirectingtogcash(),
        '/waitingconsumer': (context) => const Waitingconsumer(),
        '/estarrivalconsumer': (context) => const Estarrivalconsumer(),
        '/listrider2ongo': (context) => const Listrider2ongo(),
        '/orderriderupdate': (context) => const Orderriderupdate(),
        '/orderrecieptrider': (context) => const Orderrecieptrider(),
        '/showlistconsumer': (context) => const Showlistconsumer(),
        '/folderpage': (context) => const FolderPage(folderName: 'Unknown'),
      },
    );
  }
}
