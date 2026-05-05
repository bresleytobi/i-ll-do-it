import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:url_launcher/url_launcher.dart';
import '../errors/app_exceptions.dart';

/// Provider for PaymentService
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

/// Service to handle payment gateway integrations
class PaymentService {
  /// Create a Yoco checkout session and return the redirect URL.
  ///
  /// This calls a Supabase Edge Function so the secret key stays on the backend.
  Future<String> createYocoCheckout({
    required double amount,
    required String currency,
    required String reference,
  }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'yoco_checkout',
        body: {
          'amount': amount,
          'currency': currency,
          'reference': reference,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final url = data['checkout_url'] ?? data['checkoutUrl'] ?? data['redirect_url'] ?? data['redirectUrl'] ?? data['url'];
        if (url is String && url.isNotEmpty) {
          return url;
        }
      }

      throw ServerException('Yoco checkout did not return a valid redirect URL.');
    } catch (e) {
      throw ServerException('Failed to create Yoco checkout session: $e');
    }
  }

  /// Launch the checkout URL in the system browser
  Future<void> launchCheckout(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw ServerException('Could not launch payment gateway. Please try again.');
      }
    } catch (e) {
      throw ServerException('Error launching payment gateway: $e');
    }
  }

  /// Check payment status (Simulation)
  Future<bool> verifyPayment(String reference) async {
    try {
      // In a real app, this would poll the backend or wait for a webhook.
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }
}
