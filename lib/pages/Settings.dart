import 'package:flutter/material.dart';
import 'change_password_page.dart';
import 'TermsPage.dart';
import 'InfoPage.dart';
import 'contact.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 页面的顶部 AppBar
      appBar: AppBar(
        title: const Text('Settings'), // 页面的标题
        backgroundColor: Colors.blue, // AppBar 的背景颜色示例
      ),
      // 页面的主要内容是一个可滚动的列表
      body: ListView(
        children: <Widget>[
          // --- 账户设置部分 ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          // 修改密码选项
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            },
          ),

          const Divider(), // 分隔线

          // --- 支持与帮助部分 ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Support & Help',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          // 联系客服
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('Contact Us'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUsPage()),
              );
            },
          ),

          const Divider(), // 分隔线

          // --- 关于部分 ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          // 关于应用
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoPage()),
              );
            },
          ),
          // 隐私政策与服务条款
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy & Terms'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsPage()),
              );
            },
          ),

          // 显示版本信息
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Center(
              child: Text(
                'App Version 1.0.0',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
