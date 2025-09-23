import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path; // 导入 path 包
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 导入 dotenv
import 'dart:convert';

import 'order_success_page.dart'; // Ensure this file exists
import '../../services/auth_service.dart'; // ⭐ 导入 AuthService ⭐
import '../pages/login_and_register/login_page.dart'; // ⭐ 导入 LoginPage，用于导航 ⭐


// ⭐ 请确保 TngPaymentPage Widget 的定义完整且正确，它必须在 _TngPaymentPageState 之前定义 ⭐
class TngPaymentPage extends StatefulWidget {
  final String packageName;
  final String eventName;
  final String name;
  final String contact;
  final String address;
  final DateTime selectedDate;
  final String paymentMethod; // Receive payment method parameter
  final TimeOfDay selectedTime; // ⭐ 这里定义字段
  final List<File>? stageImages;

  const TngPaymentPage({
    super.key,
    required this.packageName,
    required this.eventName,
    required this.name,
    required this.contact,
    required this.address,
    required this.selectedDate,
    required this.paymentMethod, // Receive payment method parameter
    required this.selectedTime, // ⭐ 新增
    this.stageImages,
  });

  @override
  State<TngPaymentPage> createState() => _TngPaymentPageState();
}

// ⭐ 请确保 _TngPaymentPageState 类定义完整且正确，它必须在 TngPaymentPage 之后定义 ⭐
class _TngPaymentPageState extends State<TngPaymentPage> {
  File? _image;
  bool _isUploading = false;

  // ⭐ 实例化 AuthService ⭐
  final AuthService _authService = AuthService();


  // Image picker function - 确保这个函数完整地定义在这里面
  Future<void> _pickImage() async {
    // Request permission (Android 13+ use READ_MEDIA_IMAGES, older versions use READ_EXTERNAL_STORAGE)
    if (Platform.isAndroid) {
      final status = await Permission.photos.request(); // Android 13+
      if (!status.isGranted) {
        if (mounted) { // 检查 Widget 是否仍然挂载
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Permission to access photos is required to upload an image'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        openAppSettings(); // Guide user to app settings
        return;
      }
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  // Upload order details function - 确保这个函数完整地定义在这里面
  Future<void> _uploadOrderDetails() async {
    setState(() {
      _isUploading = true;
    });

    if (_image == null) {
      if (mounted) { // 检查 Widget 是否仍然挂载
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please upload the payment screenshot'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      setState(() {
        _isUploading = false;
      });
      return;
    }

    // ⭐ 获取 token 和处理未认证 ⭐
    final token = await _authService.getToken();

    if (!mounted) return;

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Authentication required. Please log in.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            // <-- 替换为您的登录页 Widget
                (Route<dynamic> route) => false, // 移除所有之前的页面
          );
        });
      }
      setState(() {
        _isUploading = false;
      });
      return;
    }


    final String paymentMethod = widget.paymentMethod;

    // ⭐ 从 .env 获取 BASE_URL 并构建 API URL ⭐
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Unexpected error occurred. Please try again later.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      setState(() {
        _isUploading = false;
      });
      return;
    }

    final Uri apiUrl = Uri.parse("${baseUrl}orders/");


    try {
      var request = http.MultipartRequest('POST', apiUrl);
      // ⭐ 在请求头中添加认证 token ⭐
      request.headers['Authorization'] = 'Bearer $token';
      // 对于 MultipartRequest，通常不需要设置 Content-Type 为 application/json
      // request.headers['Content-Type'] = 'application/json';

      // ⭐ 修改字段名称以匹配后端期望的 snake_case ⭐
      request.fields['package_name'] = widget.packageName; // 发送 snake_case
      request.fields['event_name'] = widget.eventName;
      request.fields['name'] = widget.name; // name 字段通常前后端一致
      request.fields['contact_number'] = widget.contact; // 发送 snake_case
      request.fields['address'] = widget.address; // address 字段通常前后端一致
      request.fields['order_date'] =
      '${widget.selectedDate.year}-${widget.selectedDate.month
          .toString()
          .padLeft(2, '0')}-${widget.selectedDate.day
          .toString()
          .padLeft(2, '0')}'; // 发送 snake_case
      request.fields['payment_method'] = paymentMethod; // 发送 snake_case
      request.fields['start_time'] =
      '${widget.selectedTime.hour.toString().padLeft(2, '0')}:${widget
          .selectedTime.minute.toString().padLeft(2, '0')}';
      if (widget.stageImages != null && widget.stageImages!.isNotEmpty) {
        for (var i = 0; i < widget.stageImages!.length; i++) {
          final file = widget.stageImages![i];
          request.files.add(await http.MultipartFile.fromPath(
            'event_images', // 建议字段用复数，后端要支持多文件
            file.path,
            filename: path.basename(file.path),
          ));
        }
      }


      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        'payment_photo', // 假设后端接收图片的字段名是 payment_photo
        _image!.path,
        filename: path.basename(_image!.path),
      ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      // ⭐ 处理响应和错误（包括 401 导航）⭐
      if (response.statusCode >= 200 &&
          response.statusCode < 300) { // 检查 2xx 状态码表示成功
        // 成功情况
        // 假设成功后后端返回的数据结构，如果需要从成功响应中获取信息
        // try { var jsonResponse = json.decode(responseBody); debugPrint('Order submission successful: $jsonResponse'); } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Order submitted successfully!'),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const OrderSuccessPage()), // 跳转到订单成功页面
          );
        }
      } else if (response.statusCode == 401) {
        // ⭐ 如果状态码是 401 Unauthorized，说明 token 无效或过期，导航到登录页 ⭐
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Unauthorized. Please log in again.'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          // 清除本地 token (可选，AuthService.logout 中会做)
          // await _authService.logout();
          // 在 UI 渲染完成后执行导航
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              // <-- 替换为您的登录页 Widget
                  (Route<dynamic> route) => false, // 移除所有之前的页面
            );
          });
        }
      }

      else if (response.statusCode == 400) {
        String errorMessage = 'Order submission failed. Please try again later';
        try {
          var jsonResponse = json.decode(responseBody);

          if (jsonResponse is Map) {
            // DRF ValidationError 通常返回 { "field_name": ["error message"] } 或 { "non_field_errors": ["error message"] }
            if (jsonResponse.containsKey('non_field_errors')) {
              errorMessage =
                  (jsonResponse['non_field_errors'] as List).join(', ');
            } else if (jsonResponse.isNotEmpty) {
              // 获取第一个字段的第一个错误
              var firstKey = jsonResponse.keys.first;
              var firstError = jsonResponse[firstKey];
              if (firstError is List && firstError.isNotEmpty) {
                errorMessage = firstError.first.toString();
              } else {
                errorMessage = firstError.toString();
              }
            }
          } else if (jsonResponse is List && jsonResponse.isNotEmpty) {
            errorMessage = jsonResponse.first.toString();
          }
        } catch (_) {
          errorMessage = 'Order submission failed. Please try again later';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } on http.ClientException catch (e) { // http 包的客户端异常
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Network error'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (error) { // 捕获其他异常
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'An unexpected error occurred. Please try again later.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // build 方法 - 确保以下 build 方法完整地定义在这里面
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "TNG Payment",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade600, Colors.blue.shade800],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Order Details Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade600,
                                      Colors.blue.shade800
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.receipt_long, color: Colors.white,
                                    size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Order Details',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildDetailItem(Icons.card_giftcard, 'Package Name',
                              widget.packageName),
                          _buildDetailItem(
                              Icons.event, 'Event Name', widget.eventName),
                          _buildDetailItem(Icons.person, 'Name', widget.name),
                          _buildDetailItem(
                              Icons.phone, 'Contact Number', widget.contact),
                          _buildDetailItem(
                              Icons.location_on, 'Address', widget.address),
                          _buildDetailItem(Icons.calendar_today, 'Booking Date',
                              '${widget.selectedDate.year}-${widget.selectedDate
                                  .month.toString().padLeft(2, '0')}-${widget
                                  .selectedDate.day.toString().padLeft(
                                  2, '0')}'),
                          _buildDetailItem(Icons.access_time, 'Booking Time',
                              '${widget.selectedTime.hour.toString().padLeft(
                                  2, '0')}:${widget.selectedTime.minute
                                  .toString().padLeft(2, '0')}'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment Instructions Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade600,
                                      Colors.green.shade800
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.qr_code_2, color: Colors.white,
                                    size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Scan QR Code for Payment',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.shade50,
                                  Colors.green.shade50
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/image/QR code.jpg',
                                width: 280,
                                height: 280,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 280,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 2),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            Icon(Icons.error_outline, size: 48,
                                                color: Colors.grey),
                                            SizedBox(height: 8),
                                            Text(
                                              'QR code failed to load',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "DuitNow Payment Information",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.business,
                                        color: Colors.blue.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Name: MyDiabolo Enterprise",
                                      style: TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(const ClipboardData(
                                        text: '012-3456789'));
                                    if (mounted) {
                                      ScaffoldMessenger
                                          .of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'DuitNow number copied'),
                                          backgroundColor: Colors.green
                                              .shade400,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(10)),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.blue.shade300),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone,
                                            color: Colors.blue.shade700,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Number: 012-3456789",
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.copy, size: 16,
                                            color: Colors.blue.shade700),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Upload Screenshot Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade600,
                                      Colors.orange.shade800
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.upload_file, color: Colors.white,
                                    size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Upload Payment Screenshot',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Required',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          GestureDetector(
                            onTap: _isUploading ? null : _pickImage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: _image != null
                                    ? Colors.transparent
                                    : Colors.grey.shade50,
                                border: Border.all(
                                  color: _image != null
                                      ? Colors.green.shade400
                                      : Colors.grey.shade400,
                                  width: 2,
                                  style: _image != null
                                      ? BorderStyle.solid
                                      : BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _image != null
                                  ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      _image!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade500,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 48,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Click to upload payment screenshot',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'JPG, PNG files supported',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : () =>
                                Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios, size: 20),
                            label: const Text(
                              "Back",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade500,
                                Colors.green.shade700
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade300,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isUploading
                                ? null
                                : _uploadOrderDetails,
                            icon: _isUploading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                                : const Icon(
                                Icons.check_circle_outline, size: 20),
                            label: Text(
                              _isUploading
                                  ? "Processing..."
                                  : "Payment Completed",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Processing Payment...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait while we verify your payment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}