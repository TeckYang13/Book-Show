import 'package:flutter/material.dart';
import '../payment/pre_order_page.dart'; // 引入 PreOrderPage

class PackageBDetailPage extends StatelessWidget {
  PackageBDetailPage({super.key, required String packageName});

  final List<String> imagePaths = [
    'assets/image/MYD8.jpg',
    'assets/image/MYD7.jpg',
    'assets/image/MYD4.jpg',
  ];

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Package B Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片轮播 + 指示器
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: imagePaths.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          imagePaths[index],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.contain, // 这样图片不会被裁剪
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imagePaths.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _pageController.hasClients && _pageController.page?.round() == index ? 12 : 8,
                          height: _pageController.hasClients && _pageController.page?.round() == index ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _pageController.hasClients && _pageController.page?.round() == index
                                ? Colors.blue
                                : Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 标题
            const Text(
              'Package B',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 描述
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Performance package suitable for any events, including:\n' // 适用于小型活动的表演套餐，包括：
                    '✅ 5-6 professional performers\n' // 5-6名专业表演者
                    '✅ 30 minutes performance time\n' // 30 分钟演出时间
                    '✅ Suitable for Chinese New Year\n' // 适合新年
                    '✅ Combination of traditional and LED diabolo performance', // 传统扯铃表演
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // 价格
            const Text(
              '💰 Price：RM 1700',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 30),

            // 预订按钮
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // 跳转到 PreOrderPage，并传递 packageName 参数
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreOrderPage(packageName: 'Package B'),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to order, navigating to pre-order page')),
                  );
                },
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
