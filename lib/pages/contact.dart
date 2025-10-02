import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  final String whatsappNumber = '60126373322'; // Replace with your actual WhatsApp number

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.chat),
          label: const Text('Contact Us via WhatsApp'),
          onPressed: () async {
            final Uri url = Uri.parse('https://wa.me/$whatsappNumber');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unable to open WhatsApp')),
              );
            }
          },
        ),
      ),
    );
  }
}
