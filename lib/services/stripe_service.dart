import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Import for Color and ThemeMode
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:Momo/consts.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<bool> makePayment(double amount) async {
    try {
      // 1. Create payment intent
      final paymentIntentClientSecret = await _createPaymentIntent(
        amount,
        "php",
      );

      if (paymentIntentClientSecret == null) {
        throw Exception('Failed to create payment intent');
      }

      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Momo",
          // Use the correct types for these properties
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.black, // Use Colors.black directly
            ),
          ),
        ),
      );

      // 3. Present and confirm payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Return success
      print("Payment completed successfully");
      return true;
    } on StripeException catch (e) {
      print('Stripe-specific error: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      print('General payment error: $e');
      return false;
    }
  }

  Future<String?> _createPaymentIntent(double amount, String currency) async {
    try {
      final Dio dio = Dio();
      final data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
        "payment_method_types[]": "card" // Explicitly specify payment method
      };

      final response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded'
          },
        ),
      );

      if (response.data != null && response.data["client_secret"] != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      print('Create payment intent error: $e');
      return null;
    }
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).round();
    return calculatedAmount.toString();
  }
}
