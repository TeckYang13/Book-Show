import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 页面导入
import 'pages/home_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/profile/edit_profile_page.dart';
import 'pages/login_and_register/login_page.dart';
import 'pages/login_and_register/register_page.dart';
import 'pages/not_found_page.dart';
import 'pages/TermsPage.dart'; // 假设这个页面存在

// 支付相关页面导入
import 'payment/pre_order_page.dart';
import 'payment/payment_selection_page.dart';
import 'payment/tng_payment_page.dart';
import 'payment/banking_payment_page.dart';

// 导入 AuthService，如果 navigatorKey 需要在此文件中设置
// import 'services/auth_service.dart'; // 根据您的 AuthService 实现是否需要在这里访问 navigatorKey

Future<void> main() async {
  // 加载 .env 文件
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ⭐ App 的标题翻译为英文 ⭐
      title: 'Performance Booking', // 表演订购
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      // onGenerateRoute 处理动态路由，特别是需要传递参数的路由
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/preOrder':
          // 确保 packageName 不为 null
            final packageName = args?['packageName'] ?? 'Default Package'; // 使用默认值
            return _generateRoute(PreOrderPage(packageName: packageName));

          case '/paymentSelection':
          // 验证并使用参数
            if (_isValidPaymentArgs(args)) {
              return _generateRoute(PaymentSelectionPage(
                packageName: args!['packageName'],
                eventName: args['eventName'],
                name: args['name'],
                contact: args['contact'],
                address: args['address'],
                selectedDate: args['selectedDate'],
                selectedTime: TimeOfDay.now(), // ⬅️ 传个默认时间
              ));
            }
            return _generateRoute(const NotFoundPage()); // 参数无效时导航到 NotFoundPage


          case '/tngPayment':
            if (_isValidPaymentArgs(args)) {
              return _generateRoute(TngPaymentPage(
                packageName: args!['packageName'],
                eventName: args['eventName'],
                name: args['name'],
                contact: args['contact'],
                address: args['address'],
                selectedDate: args['selectedDate'],
                selectedTime: args['selectedTime'], // ⭐ 新增
                paymentMethod: 'TNG', // 支付方式固定文本
              ));
            }
            return _generateRoute(const NotFoundPage()); // 参数无效时导航到 NotFoundPage


          case '/bankingPayment':
            if (_isValidPaymentArgs(args)) {
              return _generateRoute(BankingPaymentPage(
                packageName: args!['packageName'],
                eventName: args['eventName'],
                name: args['name'],
                contact: args['contact'],
                address: args['address'],
                selectedDate: args['selectedDate'],
                selectedTime: args['selectedTime'], // ⭐ 新增
                paymentMethod: 'Bank Transfer', // 支付方式固定文本
              ));
            }
            return _generateRoute(const NotFoundPage()); // 参数无效时导航到 NotFoundPage


          default:
          // 如果没有匹配的命名路由，导航到 NotFoundPage
            return _generateRoute(const NotFoundPage());
        }
      },
      // routes 处理静态路由（不需要传递复杂参数）
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainPage(),
        '/terms': (context) => TermsPage(), // 假设 TermsPage 不需要参数
        '/editProfile': (context) => const EditProfilePage(), // 假设 EditProfilePage 不需要参数
        '/notFound': (context) => const NotFoundPage(), // 假设 NotFoundPage 不需要参数
        // 如果 ProfilePage 不接受参数，也可以在这里定义静态路由
        // '/profile': (context) => const ProfilePage(),
      },
    );
  }

  // 辅助方法，用于生成 MaterialPageRoute
  MaterialPageRoute _generateRoute(Widget page) {
    return MaterialPageRoute(builder: (context) => page);
  }

  // 辅助方法，验证支付相关路由的参数是否有效
  bool _isValidPaymentArgs(Map<String, dynamic>? args) {
    return args != null &&
        args.containsKey('packageName') &&
        args.containsKey('name') &&
        args.containsKey('contact') &&
        args.containsKey('address') &&
        args.containsKey('selectedDate') && // 确保 selectedDate 存在
        args['selectedDate'] is DateTime; // 确保 selectedDate 是 DateTime 类型

  }
}

// MainPage 包含底部导航栏和不同页面
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  // 在列表中直接创建页面的 const 实例
  final List<Widget> _pages = [
    const HomePage(), // 假设 HomePage 存在且是 const
    const ProfilePage(), // 假设 ProfilePage 存在且是 const
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          // ⭐ 底部导航栏标签翻译为英文 ⭐
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), // 首页
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), // 个人主页
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}