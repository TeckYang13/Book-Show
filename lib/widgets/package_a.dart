import 'package:flutter/material.dart';
import '../payment/pre_order_page.dart'; // 引入 PreOrderPage

class PackageADetailPage extends StatelessWidget {
  PackageADetailPage({super.key, required String packageName});

  final List<String> imagePaths = [
    'assets/image/MYD1.jpg',
    'assets/image/MYD2.jpg',
    'assets/image/MYD5.jpg',
  ];

  // PageController 用于控制 PageView，StatelessWidget 通常不持有 Controller 的状态
  // Better practice in StatelessWidget is to create controller in build method or pass it
  // However, since it's used in build only, keeping it here might be acceptable for simplicity
  // But be aware of potential issues if the widget is rebuilt frequently.
  // For more complex scenarios, StatefulWidget or state management is better.
  final PageController _pageController = PageController();


  // 在 StatelessWidget 中，dispose 是没有的，PageController 需要手动管理生命周期
  // 对于简单的用例，如果 PageView 的父级管理了 Widget 的生命周期，PageController 可能会被正确处理
  // 但更安全的方式是在 StatefulWidget 中使用并 dispose PageController
  // 这里暂时保留以匹配原代码结构，但生产环境考虑重构为 StatefulWidget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ⭐ 页面标题翻译为英文 ⭐
      appBar: AppBar(title: const Text('Package A Details')), // 配套 A 详情
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
                  // 指示器部分逻辑
                  Positioned(
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imagePaths.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          // PageController.page?.round() 用于获取当前页码（可能为 null 或 double）
                          // 确保在访问之前检查 hasClients 和 page 是否不为 null
                          width: _pageController.hasClients && _pageController.page != null && _pageController.page!.round() == index ? 12 : 8,
                          height: _pageController.hasClients && _pageController.page != null && _pageController.page!.round() == index ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _pageController.hasClients && _pageController.page != null && _pageController.page!.round() == index
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

            // ⭐ 套餐标题翻译为英文 ⭐
            const Text(
              'Package A', // 配套 A
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ⭐ 描述文本翻译为英文 ⭐
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text( // 描述文本
                'Performance package suitable for any events, including:\n' // 适用于小型活动的表演套餐，包括：
                    '✅ 5-6 professional performers\n' // 5-6名专业表演者
                    '✅ 30 minutes performance time\n' // 30 分钟演出时间
                    '✅ Suitable for Chinese New Year\n' // 适合新年
                    '✅ Traditional diabolo performance', // 传统扯铃表演
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // ⭐ 价格文本翻译为英文（保留您已修改的部分并完善） ⭐
            const Text(
              '💰 Price：RM 1300', // 价格：RM 500
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
                      builder: (context) => PreOrderPage(packageName: 'Package A'), // 传递英文套餐名
                    ),
                  );
                  // ⭐ SnackBar 提示信息为英文（已在之前修改过） ⭐
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to order, navigating to pre-order page')), // 已添加到预订，跳转到预购页面
                  );
                },
                // ⭐ 按钮文本翻译为英文 ⭐
                child: const Text(
                  'Book Now', // 立即预订
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