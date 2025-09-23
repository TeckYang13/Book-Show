import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'payment_selection_page.dart';

class PreOrderPage extends StatefulWidget {
  final String packageName;

  const PreOrderPage({super.key, required this.packageName});

  @override
  _PreOrderPageState createState() => _PreOrderPageState();
}

class _PreOrderPageState extends State<PreOrderPage> {
  final TextEditingController eventNameController = TextEditingController(); // 新增事件名称控制器
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  DateTime? selectedDate; // 选择的日期
  TimeOfDay? selectedTime; // 选择的开始时间
  List<File> stageImages = []; // 存储选择的舞台示例图片
  final ImagePicker _picker = ImagePicker();

  // 日期选择器
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)), // 只允许选择未来 1 年
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // 时间选择器
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // 图片选择器
  Future<void> _selectImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('拍照'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (stageImages != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('移除图片'),
                  onTap: () {
                    setState(() {
                      stageImages.clear(); // ✅ 清空所有
                    });
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          stageImages.add(File(pickedFile.path)); // ✅ 添加到列表
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    int price = 0;

    if (widget.packageName == 'Package A') {
      price = 1300;
    } else if (widget.packageName == 'Package B') {
      price = 1700;
    } else if (widget.packageName == 'Package C') {
      price = 3000;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Pre-order - ${widget.packageName}'),
        backgroundColor: Colors.blue.shade800,
        elevation: 8,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package details
            const SizedBox(height: 20),
            Text(
              'You have selected the package: ${widget.packageName}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 20),

            // Package description
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Confirm your booking information and proceed to payment.',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Price information
            Text(
              '💰 Price: RM $price',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 30),

            // Enter Event Name
            TextField(
              controller: eventNameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.event),
              ),
            ),
            const SizedBox(height: 20),

            // Enter name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nickname Or Company Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            // Enter contact info
            TextField(
              controller: contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),

            // Enter address
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Performance Place Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 20),

            // Select date
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'Please select performance date'
                        : 'Booking Date: ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Select time
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTime == null
                        ? 'Please select performance start time'
                        : 'Start Time: ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time, color: Colors.blue),
                  onPressed: () => _selectTime(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stage Image Upload Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.image, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Stage Sample Image (Optional)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Upload a sample image of your desired stage setup',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  if (stageImages.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: stageImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                stageImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _selectImage,
                      icon: const Icon(Icons.add_a_photo),
                      label: Text(stageImages.isEmpty ? 'Add Image' : 'Add More'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Confirm booking button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: Colors.blue.shade300,
                ),
                onPressed: () {
                  if (eventNameController.text.isEmpty ||
                      nameController.text.isEmpty ||
                      contactController.text.isEmpty ||
                      addressController.text.isEmpty ||
                      selectedDate == null ||
                      selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all required information!')),
                    );
                    return;
                  }

                  // Navigate to the payment selection page and pass the user's input information
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSelectionPage(
                        packageName: widget.packageName,
                        eventName: eventNameController.text, // 传递事件名称
                        name: nameController.text,
                        contact: contactController.text,
                        address: addressController.text,
                        selectedDate: selectedDate!,
                        selectedTime: selectedTime!,
                        stageImages: stageImages,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Confirm Order',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    eventNameController.dispose();
    nameController.dispose();
    contactController.dispose();
    addressController.dispose();
    super.dispose();
  }
}