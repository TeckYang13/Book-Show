import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'), // 标题已翻译为英文
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 返回上一页
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('User Agreement', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(
              '''By using our application (hereinafter referred to as "the App"), you agree to comply with the following terms and conditions. If you do not agree with these terms and conditions, please cease using the App immediately.

1. Eligibility  
The App is only available to legal users who are at least 18 years old (or the legal age in your jurisdiction). If you do not meet this requirement, please refrain from using the App.

2. User Account  
You need to register and create an account to use the App. You are responsible for providing accurate and complete information during registration and updating it as necessary. You are also responsible for maintaining the security of your account information and agree not to disclose your login credentials to third parties.

3. License to Use  
We grant you a limited, non-exclusive, non-transferable license to access and use the features of the App. Unless otherwise stated by law, you may not copy, distribute, modify, or sell any part of the App without authorization.

4. Prohibited Actions  
You may not use the App for any illegal, malicious, or infringing activities, including but not limited to identity theft, publishing inappropriate content, or disrupting the normal operation of the services.

5. Intellectual Property  
The App and all its content (including but not limited to text, images, audio and video, code, etc.) are the property of us or our licensors and are protected by intellectual property laws.

6. Disclaimer and Limitation of Liability  
The App is provided "as is," and we make no guarantees regarding the accuracy, completeness, or reliability of its content.  
We are not liable for any damage or loss arising from your use of the App unless required by law.

7. Privacy Policy  
Your personal information provided while using the App will be handled according to our privacy policy, which can be found for more details.

8. Modification of Terms  
We reserve the right to modify or update the terms of this agreement at any time, with the updated terms becoming effective immediately upon being published in the App.
              ''',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text('Privacy Policy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(
              '''This Privacy Policy (hereinafter referred to as "Policy") describes how we collect, use, share, and protect your personal information. By using the App, you agree to the processing of your information as described in this Policy.

1. Information We Collect  
- **Personal Information**: When registering or using services, we collect your name, email, address, phone number, etc.  
- **Technical Information**: We may also collect device information, operating system, IP address, browser type, pages, and features used.  
- **Payment Information**: If you make purchases or payments within the App, we may collect payment-related information.

2. How We Use Your Information  
- **Service Provision**: We use your personal information to provide app features and services, such as order management, notifications, etc.  
- **Analytics and Improvement**: We use collected technical information to understand user needs and improve the app's functionality and user experience.  
- **Advertising and Marketing**: With your consent, we may use your information to offer customized advertisements or promotional campaigns.

3. How We Share Your Information  
- **Third-Party Service Providers**: We may share your information with third-party providers (e.g., payment processors, cloud storage, etc.) to provide services.  
- **Legal Requirements**: We may disclose your information if required by law or to protect our rights, property, and safety.

4. Information Security  
We implement reasonable technical and administrative measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction.  
However, while we take these steps, we cannot guarantee absolute security. By using the App, you acknowledge this risk.

5. Your Rights  
You can access, update, or delete your personal information at any time.  
You can also opt-out of receiving marketing messages if you prefer.

6. Updates to This Policy  
We may update this Privacy Policy periodically, and the updated policy will be published in the App and take effect immediately.
              ''',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text('Security Terms', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(
              '''To ensure the security of your account and data protection, please follow the following security terms when using the App:

1. Account Security  
You are responsible for protecting your account information, including login credentials and passwords. We recommend using a strong password and changing it regularly.  
Do not share your account information with anyone. If you suspect your account has been compromised or abused, change your password immediately and contact us.

2. Data Encryption and Protection  
We use industry-standard encryption technologies (such as SSL/TLS) to protect data transmitted within the App.  
All sensitive data (such as payment information) is encrypted to ensure security.

3. Prevention of Unauthorized Activities  
Any unauthorized access, data collection, or attacks on the App’s system are strictly prohibited.  
We will implement appropriate measures to detect and prevent malicious activities, including denial-of-service attacks and SQL injection.

4. Security Vulnerability Reporting  
If you detect any security vulnerabilities or abnormal behavior in the App, please contact us immediately. We will work to fix and improve these issues as soon as possible.

5. Legal Liability  
If you violate these security terms and cause any data loss, leakage, or other security incidents, you will be held legally responsible.

6.Data Security and Incident Response
We are committed to protecting the security of your data by implementing industry-standard security measures. However, in the event of unavoidable cyber attacks or force majeure, data risks may still arise.
If a security incident occurs, we will immediately suspend the affected services and promptly notify users. You have the right to be informed of the impact of the incident and to request the deletion of any related information.
              ''',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
