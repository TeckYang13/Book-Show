import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page Not Found")), // "页面未找到" 改为英文 "Page Not Found"
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text(
              "404 - Page Not Found", // "404 - 页面未找到" 改为英文 "404 - Page Not Found"
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("The page you are looking for does not exist. Please check if the URL is correct."), // "您访问的页面不存在，请检查URL是否正确" 改为英文
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("✅ Go to Home clicked");
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Go to Home"), // "返回login" 改为英文 "Go to Home"
            ),
          ],
        ),
      ),
    );
  }
}
