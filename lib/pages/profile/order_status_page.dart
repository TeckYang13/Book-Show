import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ 新增
import 'dart:convert';
import '../../services/auth_service.dart'; // 导入 AuthService
import '../login_and_register/login_page.dart'; // 导入 LoginPage

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;
  final AuthService _authService = AuthService(); // 实例化 AuthService

  @override
  void initState() {
    super.initState();
    _fetchOrders(); // 页面初始化时获取订单数据
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null; // 清除之前的错误信息
    });

    // ⭐ 1. 从 AuthService 获取 token ⭐
    final token = await _authService.getToken();

    if (!mounted) return; // 检查 Widget 是否仍然挂载

    if (token == null) {
      // ⭐ 如果没有 token，说明未登录，导航到登录页 ⭐
      debugPrint("OrderStatusPage: 未找到 token，导航到登录页");
      setState(() {
        _isLoading = false; // 加载完成（虽然会立即跳转）
      });
      // 在 UI 渲染完成后执行导航
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()), // <-- 替换为您的登录页 Widget
              (Route<dynamic> route) => false, // 移除所有之前的页面
        );
      });
      return; // 结束加载过程
    }

    // ⭐ 2. 如果有 token，构建正确的 URL 并发送请求 ⭐
    final baseUrl = dotenv.env['BASE_URL']; // 从 .env 获取基础 URL
    if (baseUrl == null) {
      if(mounted) { // 检查 Widget 是否仍然挂载
        setState(() {
          _error = '.env file not loaded or BASE_URL not found.'; // 设置错误信息（英文）
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }
      return;
    }

    // 假设 BASE_URL 包含 /api/，例如 http://172.20.10.5:8000/api/
    // 那么相对路径就是 orders/list/
    final url = Uri.parse("${baseUrl}orders/list/"); // ⭐ 确保 URL 拼接正确 ⭐


    try {
      debugPrint("OrderStatusPage: 使用 token 发送订单列表请求到 $url");
      final response = await http.get(
        url,
        // ⭐ 3. 在请求头中携带 token ⭐
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // 添加 Content-Type 以确保后端正确解析
        },
      );

      if (!mounted) return; // 检查 Widget 是否仍然挂载

      if (response.statusCode == 200) {
        // 成功获取订单数据
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        debugPrint("OrderStatusPage: 成功加载 ${data.length} 条订单数据");
        setState(() {
          _orders = data;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // ⭐ 如果状态码是 401 Unauthorized，说明 token 无效或过期，导航到登录页 ⭐
        debugPrint("OrderStatusPage: 收到 401 Unauthorized，导航到登录页");
        // 清除本地 token
        await _authService.logout(); // 调用 logout 方法清除 token
        setState(() {
          _isLoading = false;
          _error = 'Unauthorized. Please log in again.'; // 设置错误信息（英文）
        });
        // 在 UI 渲染完成后执行导航
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()), // <-- 替换为您的登录页 Widget
                (Route<dynamic> route) => false, // 移除所有之前的页面
          );
        });
      }
      else {
        // 其他非 200 状态码，认为是失败
        debugPrint("OrderStatusPage: 加载订单失败，状态码: ${response.statusCode}");
        debugPrint("OrderStatusPage: 响应体: ${utf8.decode(response.bodyBytes)}");
        setState(() {
          _error = 'Failed to load orders (Status code: ${response.statusCode})'; // 错误信息翻译为英文
          _isLoading = false;
        });
      }
    } catch (e) {
      // 捕获网络请求或其他异常
      debugPrint("OrderStatusPage: 加载订单时发生异常: $e");
      if (!mounted) return; // 检查 Widget 是否仍然挂载
      setState(() {
        _error = 'An error occurred while retrieving orders. Please try again later.'; // 错误信息翻译为英文
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Status'), // 页面标题（已翻译）
        backgroundColor: Colors.blue.shade700,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 加载中
          : _error != null
          ? Center(child: Text('Error: $_error')) // 显示错误信息
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: _orders.isEmpty
            ? const Center(child: Text('No orders found.')) // 没有订单提示（已翻译）
            : ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            final rawStatus = order['status'];
            final orderDate = order['order_date'] ?? order['created_at'] ?? 'Unknown'; // 订单日期字段

            // ✅ 状态翻译逻辑（保持不变）
            String status;
            if (rawStatus == '待处理') {
              status = 'Pending';
            } else if (rawStatus == '已完成') {
              status = 'Completed';
            } else if (rawStatus == '已取消') {
              status = 'Cancelled';
            } else {
              status = rawStatus ?? 'Unknown'; // 如果后端返回其他状态，直接显示或显示Unknown
            }

            // 根据状态设置卡片颜色和图标
            Color cardColor;
            Color textColor;
            Color iconColor;
            IconData icon;

            if (status == 'Pending') {
              cardColor = Colors.grey.shade300;
              textColor = Colors.grey.shade800;
              iconColor = Colors.grey.shade700;
              icon = Icons.hourglass_empty;
            } else if (status == 'Completed') {
              cardColor = Colors.green.shade100;
              textColor = Colors.green.shade800;
              iconColor = Colors.green.shade700;
              icon = Icons.check_circle;
            } else if (status == 'Cancelled') {
              cardColor = Colors.red.shade100;
              textColor = Colors.red.shade600;
              iconColor = Colors.red.shade500;
              icon = Icons.cancel;
            } else {
              cardColor = Colors.blueGrey.shade50;
              textColor = Colors.black;
              iconColor = Colors.black54;
              icon = Icons.help_outline;
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              color: cardColor,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                // ⭐ 订单详情文本翻译为英文 ⭐
                title: Text(
                  'Order ID: ${order['id'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  'Status: $status\nPackage: ${order['package_name'] ?? 'N/A'}\nCustomer: ${order['name'] ?? 'N/A'}\nAddress: ${order['address'] ?? 'Unknown'}\nDate: ${orderDate}', // 确保 date 字段正确显示
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: Icon(
                  icon,
                  color: iconColor,
                ),
                onTap: () {
                  // 您可以在这里添加导航到订单详情页的逻辑
                },
              ),
            );
          },
        ),
      ),
    );
  }
}