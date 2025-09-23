import 'package:flutter/material.dart';
import 'package:lasttime/widgets/package_a.dart'; // 配套 A 详细页面
import 'package:lasttime/widgets/package_b.dart'; // 配套 B 详细页面
import 'package:lasttime/widgets/package_c.dart'; // 配套 C 详细页面

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  final List<String> bannerImages = [
    'assets/image/LWJ1.jpg',
    'assets/image/LWJ2.jpg',
    'assets/image/MYD3.jpg',
    'assets/image/MYD6.jpg',
  ];

  final List<Map<String, String>> packages = [
    {
      'name': 'Package A',
      'description': 'Performance package for any events',
      'image': 'assets/image/logo 2.jpg'
    },
    {
      'name': 'Package B',
      'description': 'Performance package for any events',
      'image': 'assets/image/logo 2.jpg'
    },
    {
      'name': 'Package C',
      'description': 'Performance package for any events',
      'image': 'assets/image/logo 2.jpg'
    },
  ];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ❗隐藏返回按钮
        title: const Text("Home"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 5,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // 轮播图
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    height: 250, // 让轮播图更大一点
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: bannerImages.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          bannerImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Center(
                                child: Text('Failed to load image', style: TextStyle(color: Colors.white)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      bannerImages.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: _currentPage == index ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index ? Colors.blue.shade700 : Colors.grey,
                          boxShadow: _currentPage == index
                              ? [BoxShadow(color: Colors.blue.shade700, blurRadius: 4)]
                              : [],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 配套标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Featured Packages',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // 配套列表
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: packages.map((package) {
                return GestureDetector(
                  onTap: () {
                    String selectedPackage = package['name']!;
                    if (selectedPackage == 'Package A') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PackageADetailPage(packageName: selectedPackage)),
                      );
                    } else if (selectedPackage == 'Package B') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PackageBDetailPage(packageName: selectedPackage)),
                      );
                    } else if (selectedPackage == 'Package C') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PackageCDetailPage(packageName: selectedPackage)),
                      );
                    }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: Colors.blue.shade200,
                    margin: const EdgeInsets.only(bottom: 16), // 让卡片之间留出间隔
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: AspectRatio(
                            aspectRatio: 16 / 9, // 让图片按 16:9 比例显示
                            child: Image.asset(
                              package['image']!,
                              fit: BoxFit.contain, // 让图片完整显示
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                package['name']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                package['description']!,
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
