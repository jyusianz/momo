import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Momo/consts.dart';
import 'package:Momo/firebase_options.dart';
import 'package:Momo/showlistconsumer.dart';
import 'package:Momo/rider.dart';
import 'package:Momo/signup_rider.dart';
import 'package:Momo/signin_rider.dart';
import 'package:Momo/verificationRider.dart';
import 'package:Momo/completeprofileRider.dart';
import 'package:Momo/riderHome.dart';
import 'package:Momo/listrider.dart';
import 'package:Momo/riderprofile.dart';
import 'package:Momo/orderdetails.dart';
import 'package:Momo/editprofilerider.dart';
import 'package:Momo/manageaddressrider.dart';
import 'package:Momo/paymentmethodrider.dart';
import 'package:Momo/settingsrider.dart';
import 'package:Momo/helpcenterrider.dart';
import 'package:Momo/privacypolicyrider.dart';
import 'package:Momo/consumer.dart';
import 'package:Momo/welcomeScreen.dart';
import 'package:Momo/signup_consumer.dart';
import 'package:Momo/signin_consumer.dart';
import 'package:Momo/verificationConsumer.dart';
import 'package:Momo/completeprofileconsumer.dart';
import 'package:Momo/consumerHome.dart';
import 'package:Momo/listconsumer.dart';
import 'package:Momo/consumerprofile.dart';
import 'package:Momo/editprofileconsumer.dart';
import 'package:Momo/manageaddressconsumer.dart';
import 'package:Momo/paymentmethodconsumer.dart';
import 'package:Momo/settingsconsumer.dart';
import 'package:Momo/helpcenterconsumer.dart';
import 'package:Momo/privacypolicyconsumer.dart';
import 'package:Momo/inputlistconsumer.dart';
import 'package:Momo/waitingconsumer.dart';
import 'package:Momo/estarrivalconsumer.dart';
import 'package:Momo/Listrider2ongo.dart';
import 'package:Momo/riderOrderConfirmationPage.dart';
import 'package:Momo/orderrecieptrider.dart';
import 'package:Momo/folderpage.dart';
import 'package:Momo/orderConfirmationPage1.dart';
import 'package:Momo/orderConfirmationPage2.dart';
import 'package:Momo/orderConfirmationPage3.dart';
import 'package:Momo/shoppingInProgress.dart';
import 'package:Momo/deliveryPage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:Momo/chatListScreen.dart';
import 'package:Momo/chatScreen.dart';
import 'utils/user.dart';

Future<void> main() async {
  // Initialize Flutter bindings once
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase could not initialize: $e');
  }

  // Initialize Stripe
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();

  runApp(const MomoApp());
}

class MomoApp extends StatelessWidget {
  const MomoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momo App',
      debugShowCheckedModeBanner: false,
      // Change initial route to a screen that definitely exists
      home: const Home(), // Assuming WelcomeScreen exists from your imports
      routes: {
        '/user': (context) => const User(),
        '/rider': (context) => const Rider(),
        '/consumer': (context) => const Consumer(),
        '/signup_rider': (context) => const Signup_rider(),
        '/signup_consumer': (context) => const SignupConsumer(),
        '/signin_rider': (context) => const Signin_rider(),
        '/signin_consumer': (context) => const Signin_consumer(),
        '/verificationRider': (context) => const VerificationRider(),
        '/verificationConsumer': (context) => const VerificationConsumer(),
        '/completeprofileRider': (context) => const CompleteProfileRider(),
        '/riderHome': (context) => const RiderHome(),
        '/listrider': (context) => const Listrider(),
        '/riderprofile': (context) => const Riderprofile(),
        '/orderdetails': (context) => const OrderDetailsPage(orderId: ''),
        '/completeprofileconsumer': (context) =>
            const CompleteProfileConsumer(),
        '/editprofilerider': (context) => const Editprofilerider(),
        '/manageaddressrider': (context) => const Manageaddressrider(),
        '/paymentmethodrider': (context) => const Paymentmethodrider(),
        '/settingsrider': (context) => const Settingsrider(),
        '/helpcenterrider': (context) => const Helpcenterrider(),
        '/privacypolicyrider': (context) => const Privacypolicyrider(),
        '/consumerHome': (context) => const ConsumerHome(),
        '/listconsumer': (context) => const Listconsumer(),
        '/consumerprofile': (context) => const Consumerprofile(),
        '/editprofileconsumer': (context) => const Editprofileconsumer(),
        '/manageaddressconsumer': (context) => const Manageaddressconsumer(),
        '/paymentmethodconsumer': (context) => const Paymentmethodconsumer(),
        '/settingsconsumer': (context) => const Settingsconsumer(),
        '/helpcenterconsumer': (context) => const Helpcenterconsumer(),
        '/privacypolicyconsumer': (context) => const Privacypolicyconsumer(),
        '/inputlistconsumer': (context) => const Inputlistconsumer(),
        '/waitingconsumer': (context) => const Waitingconsumer(),
        '/estarrivalconsumer': (context) => const Estarrivalconsumer(),
        '/listrider2ongo': (context) => const Listrider2ongo(),
        '/riderOrderConfirmationPage': (context) =>
            const RiderOrderConfirmationPage(orderId: ''),
        '/orderrecieptrider': (context) => const Orderrecieptrider(),
        '/showlistconsumer': (context) => const Showlistconsumer(),
        // Modified these routes to handle parameters properly
        '/folderpage': (context) => const FolderPage(folderName: ''),
        '/orderConfirmationPage1': (context) =>
            const OrderConfirmationPage1(orderId: ''),
        '/orderConfirmationPage2': (context) =>
            const OrderConfirmationPage2(orderId: ''),
        '/orderConfirmationPage3': (context) =>
            const OrderConfirmationPage3(orderId: ''),
        '/shoppingInProgress': (context) =>
            const ShoppingInProgressPage(orderId: ''),
        '/deliveryPage': (context) => const Deliverypage(orderId: ''),
        '/chatListScreen': (context) => const ChatListScreen(),
        '/chatScreen': (context) => const ChatScreen(chatId: ''),
      },
    );
  }
}
