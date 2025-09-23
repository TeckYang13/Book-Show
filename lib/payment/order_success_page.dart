import 'package:flutter/material.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Successful"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green.shade600),
            const SizedBox(height: 20),
            const Text(
              "Thank you for your payment!\nYour order has been successfully submitted.\nWe will process it within 48 hours.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Directly return to the HomePage
                Navigator.pushReplacementNamed(context, '/main');
              },
              child: const Text("Back to Home Page"),
            ),
          ],
        ),
      ),
    );
  }
}
