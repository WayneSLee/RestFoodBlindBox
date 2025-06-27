import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restfoodblindbox/pages/role_selection_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // ... (createUserWithEmailAndPassword 邏輯不變)

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('註冊成功，歡迎 ${_nameController.text}')),
          );

          // 👇 --- 修改導航邏輯 --- 👇
          // 原本是 Navigator.pop(context);
          // 現在改成導向到身份選擇頁面，並清除所有舊的頁面堆疊
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                  (route) => false
          );
          // 👆 --- 修改導航邏輯 --- 👆
        }

      } on FirebaseAuthException catch (e) {
        // ... (錯誤處理不變)
      } finally {
        // ... (finally 區塊不變)
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ... (build 方法和 validator 不變) ...
  // build 方法中可以加入 _isLoading 的判斷來顯示 CircularProgressIndicator
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('註冊')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            // ... (您的 TextFormField)
            children: [
              Text('建立新帳號', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '姓名', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? '請輸入姓名' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: _validateEmail,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: '密碼', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? '請輸入密碼' : null,
              ),
              SizedBox(height: 24),
              if (_isLoading)
                CircularProgressIndicator()
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _submitRegister,
                      child: Text('註冊'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('已經有帳號？返回登入'),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return '請輸入 Email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Email 格式錯誤';
    return null;
  }
}