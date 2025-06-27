import 'package:flutter/material.dart';
import 'package:restfoodblindbox/pages/main_page.dart';
import 'package:restfoodblindbox/pages/store_dashboard_page.dart';
import 'package:restfoodblindbox/services/api_service.dart';

class StoreRegistrationPage extends StatefulWidget {
  const StoreRegistrationPage({super.key});

  @override
  State<StoreRegistrationPage> createState() => _StoreRegistrationPageState();
}

class _StoreRegistrationPageState extends State<StoreRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController(); // 為了簡化，先用輸入框處理圖片 URL

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // 驗證表單
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 1. 從 Controllers 建立要發送到 API 的資料 Map
      final storeData = {
        "name": _nameController.text,
        "address": _addressController.text,
        "category": _categoryController.text,
        "description": _descriptionController.text,
        "imageUrl": _imageUrlController.text,
      };

      try {
        // 2. 接收從 API 回傳的新 storeId
        final newStoreId = await ApiService.createStore(storeData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('店家資料已提交！歡迎加入！')),
          );

          // 3. 使用 newStoreId 導航到店家儀表板
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => StoreDashboardPage(storeId: newStoreId),
            ),
                (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('提交失敗: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('申請成為店家'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '店家名稱'),
                validator: (value) => value!.isEmpty ? '請輸入店家名稱' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: '店家地址'),
                validator: (value) => value!.isEmpty ? '請輸入店家地址' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: '店家類別 (例如: 台灣小吃, 手搖飲)'),
                validator: (value) => value!.isEmpty ? '請輸入店家類別' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '店家描述'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? '請輸入店家描述' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: '店家照片 URL'),
                keyboardType: TextInputType.url,
                validator: (value) => value!.isEmpty ? '請提供店家照片的 URL' : null,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('提交申請'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}