import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // 导入 GlobalKey 和 navigatorKey
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 导入 Flutter Secure Storage
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 导入 flutter_dotenv
import 'dart:convert'; // 用于 jsonEncode 和 jsonDecode
import 'package:http/http.dart' as http; // 用于 http 请求
// import 'dart:developer' as developer; // ⭐ 导入 developer 包并使用前缀 ⭐

// 需要在 MaterialApp 或 CupertinoApp 中设置 navigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['BASE_URL'] ?? "https://bookshow.up.railway.app/api/",
    // 从 .env 文件中获取 BASE_URL
    connectTimeout: Duration(seconds: 10),
    // 连接超时
    receiveTimeout: Duration(seconds: 10),
    // 接收超时
    headers: {"Content-Type": "application/json"}, // 确保使用 JSON
  ));

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage(); // 实例化 Flutter Secure Storage
  final String baseUrl = dotenv.env['BASE_URL'] ??
      "https://bookshow.up.railway.app/api/"; // base URL

  // ---------- Token 存取 (使用 Flutter Secure Storage) ----------

  /// 从安全存储中读取 token
  Future<String?> getToken() async {
    try {
      String? token = await _secureStorage.read(key: 'token');
      return token;
    } catch (e) {
      return null; // 读取失败也返回 null
    }
  }

  /// 将 token 写入安全存储
  Future<void> _saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'token', value: token);
    } catch (e) {}
  }

  /// 从安全存储中删除 token (用于退出登录)
  Future<void> _removeToken() async {
    try {
      await _secureStorage.delete(key: 'token');
    } catch (e) {}
  }

  // ---------- 响应判断 ----------

  bool _isSuccess(Response response) {
    return (response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null &&
        response.data.containsKey('success') && // 添加键存在检查
        response.data['success'] == true;
  }

  // ---------- 错误处理 (返回英文错误信息) ----------
  String? _handleDioError(DioException e) {
    if (e.response != null) {
      if (e.response!.data != null && e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        return e.response!.data['message']; // 返回后端提供的错误信息
      }
      if (e.response!.data != null && e.response!.data is Map &&
          e.response!.data.containsKey("errors") &&
          e.response!.data["errors"] is Map) {
        Map<String, dynamic> errors = e.response!.data["errors"];
        if (errors.isNotEmpty && errors.values.first is List &&
            errors.values.first.isNotEmpty) {
          return errors.values.first.first.toString(); // 返回后端提供的第一个错误信息
        }
      }
      String errorMessage = 'Request failed';
      if (e.response?.statusMessage != null) {
        errorMessage += ' - ${e.response?.statusMessage}';
      }
      return errorMessage;
    } else {
      return 'Network error';
    }
  }

  // ---------- 认证相关方法 ----------

  /// 用户登录
  Future<String?> loginUser(String gmail, String password) async {
    try {
      Response response = await _dio.post(
        'login/', // Django 后端的登录接口
        data: {
          "gmail": gmail, // Django 后端字段名
          "password": password
        },
      );

      if (_isSuccess(response)) { // 使用 _isSuccess 方法统一判断成功
        if (response.data.containsKey('access')) {
          await _saveToken(
              response.data['access']); // 保存 token 使用 Flutter Secure Storage
        }
        return null; // 登录成功返回 null
      } else {
        return _handleDioError(DioException(
            requestOptions: response.requestOptions,
            response: response)); // 返回处理后的英文错误信息
      }
    } on DioException catch (e) {
      return _handleDioError(e); // 处理 Dio 异常并返回错误信息
    } catch (e) {
      return "Unknown error"; // 返回英文未知错误信息
    }
  }

  /// 用户注册
  Future<String?> registerUser(String name, String gmail,
      String password) async {
    try {
      Response response = await _dio.post(
        'register/', // Django 后端的注册接口
        data: {
          "name": name, // Django 后端字段名
          "gmail": gmail,
          "password": password
        },
      );

      if (_isSuccess(response)) { // 使用 _isSuccess 方法统一判断成功
        if (response.data != null && response.data.containsKey('access')) {
          await _saveToken(response.data['access']); // Token 保存成功时
        }
        return null; // 注册成功返回 null
      } else {
        return _handleDioError(DioException(
            requestOptions: response.requestOptions,
            response: response)); // 返回处理后的英文错误信息
      }
    } on DioException catch (e) {
      return _handleDioError(e); // 处理 Dio 异常并返回错误信息
    } catch (e) {
      return "Unknown error"; // 返回英文未知错误信息
    }
  }

  /// 获取用户信息
  Future<Map<String, dynamic>?> getUserProfile(String token) async {
    try {
      final response = await _dio.get(
        'profile/', // Django 后端的 profile 接口
        options: Options(
          headers: {'Authorization': 'Bearer $token'}, // 在请求头中携带 token
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        _handleDioError(DioException(requestOptions: response.requestOptions,
            response: response)); // 错误处理
        return null; // 返回 null 表示获取失败
      }
    } on DioException catch (e) {
      _handleDioError(e); // 打印错误信息
      return null; // 返回 null 表示获取失败
    } catch (e) {
      return null; // 返回 null 表示获取失败
    }
  }

  /// 更新用户资料
  Future<bool> updateUserProfile(Map<String, dynamic> updatedData) async {
    try {
      final token = await getToken();
      if (token == null) {
        return false; // 返回 false 表示失败（未登录）
      }

      Response response = await _dio.put(
        'update-profile/', // Django 后端的更新接口
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        // 携带 token
        data: updatedData, // 更新数据
      );

      if (response.statusCode == 200) {
        return true; // 返回 true 表示成功
      } else {
        _handleDioError(DioException(requestOptions: response.requestOptions,
            response: response)); // 错误处理
        return false; // 返回 false 表示失败
      }
    } on DioException catch (e) {
      _handleDioError(e); // 处理 Dio 异常
      return false; // 返回 false 表示失败
    } catch (e) {
      return false; // 返回 false 表示失败
    }
  }

  /// 删除用户账户
  Future<bool> deleteUserAccount() async {
    try {
      final token = await getToken();
      if (token == null) {
        return false; // 返回 false 表示失败（未登录）
      }

      Response response = await _dio.delete(
        'delete-account/', // 假设后端有删除账户的接口
        options: Options(
            headers: {'Authorization': 'Bearer $token'}), // 携带 token
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _removeToken(); // 删除账户成功后清除 token
        return true; // 删除账户成功，返回 true
      } else {
        _handleDioError(DioException(requestOptions: response.requestOptions,
            response: response)); // 错误处理
        return false; // 返回 false 表示失败
      }
    } on DioException catch (e) {
      _handleDioError(e); // 处理 Dio 异常
      return false; // 返回 false 表示失败
    } catch (e) {
      return false; // 返回 false 表示失败
    }
  }

  /// 修改密码
  // 注意：AuthService 内部获取 token
  Future<String?> changePassword(String oldPassword, String newPassword) async {
    // ⭐ 在这里获取 token ⭐
    final token = await getToken(); // AuthService 内部获取 token
    if (token == null) {
      // 移除或翻译调试输出
      // debugPrint("AuthService: No token available for changePassword.");
      return "Authentication required. Please log in."; // 翻译为英文
    }

    try {
      final response = await _dio.post(
        'change-password/', // 假设修改密码接口是 /api/user/password/change/
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // ⭐ 使用获取到的 token ⭐
          },
        ),
        data: jsonEncode({
          'oldPassword': oldPassword, // ⭐ 根据后端期望的键名进行调整 ⭐
          'newPassword': newPassword, // ⭐ 根据后端期望的键名进行调整 ⭐
        }),
      );

      if (response.statusCode == 200) {
        // 移除或翻译调试输出
        // debugPrint("AuthService: Password changed successfully.");
        return "Password changed successfully"; // 翻译为英文
      } else if (response.statusCode == 400) {
        // 后端返回的验证错误，例如旧密码错误
        // 移除或翻译调试输出
        // debugPrint("AuthService: Change password failed (400): ${response.data}");
        return response.data['message'] ?? 'Password change failed'; // 返回后端提供的错误信息，翻译为英文
      } else if (response.statusCode == 401) {
        // Token 无效或过期
        await logout();
        // 移除或翻译调试输出
        // debugPrint("AuthService: Token expired or invalid for changePassword.");
        return "Unauthorized. Please log in again."; // 翻译为英文 (需要重新登录)
      }
      else {
        // 其他错误
        // 移除或翻译调试输出
        // debugPrint("AuthService: Change password failed (Status ${response.statusCode}): ${response.data}");
        return "An unexpected error occurred during password change"; // 翻译为英文
      }
    } on DioError catch (e, stacktrace) { // 捕获 Dio 错误及堆栈信息
      // 翻译调试输出为英文
      // developer.log("AuthService: Dio Error during changePassword: ${e.message}", stackTrace: stacktrace);
      if (e.response?.statusCode == 401) {
        await logout();
      }
      return "Current password wrong"; // 翻译为英文
    } catch (e, stacktrace) { // 捕获其他错误及堆栈信息
      // 翻译调试输出为英文
      // developer.log("AuthService: Unexpected Error during changePassword: $e", stackTrace: stacktrace);
      return "An unexpected error occurred during password change"; // 翻译为英文
    }
  }

  /// 退出登录方法
  Future<String?> logout() async {
    final token = await getToken();
    if (token == null) return "No token found"; // 如果没有 token 返回错误信息

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}logout/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 不管 logout 是否成功都移除本地 token
      await _removeToken();

      if (response.statusCode == 200) {
        return "Logout successful"; // 返回登出成功消息
      } else {
        return "Logout failed"; // 如果请求失败返回错误信息
      }
    } catch (e) {
      return "Network error. Please try again."; // 如果网络请求失败
    }
  }
}

