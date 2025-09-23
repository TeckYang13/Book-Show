import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            // 应用名称
            InfoTile(title: "App Name", value: "Mydiabolo App"),
            // 应用版本
            InfoTile(title: "Version", value: "v1.0.0"),
            // 开发团队简介（简化+英文）
            InfoTile(title: "Development Team", value: "A group of tech enthusiasts passionate about performance and booking platforms."),
            // 删除真实姓名，仅保留角色
            InfoTile(title: "Main Developers", value: "Lead developers and contributors"),
            // 联系方式（保持通用格式）
            InfoTile(title: "Contact", value: "mydiabolo@gmail.com"),
            // 应用简介（英文）
            InfoTile(
              title: "App Description",
              value: "This app provides a fast and convenient way to book personal performances and aims to promote diabolo culture.",
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const InfoTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
