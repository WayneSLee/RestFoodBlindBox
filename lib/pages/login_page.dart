import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:restfoodblindbox/pages/main_page.dart';
import 'package:restfoodblindbox/pages/register_page.dart';
import 'package:restfoodblindbox/pages/role_selection_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // 用於顯示載入指示器

  // Firebase Auth 實例
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 傳統 Email/密碼登入
  Future<void> _submitLogin() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // 登入成功後，authStateChanges 會監聽到變化，可以由 AuthWrapper 處理跳轉
      // 為了簡單起見，這裡直接跳轉
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? '登入失敗')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Google 登入邏輯
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 1. 取得登入後的 UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // 2. 判斷是否為新使用者
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (mounted) {
        if (isNewUser) {
          // 3. 如果是新使用者，導向到身份選擇頁面
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                (route) => false,
          );
        } else {
          // 4. 如果是舊使用者，導向到主頁面
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google 登入失敗: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登入')),
      body: Center( // 改用 Center 和 SingleChildScrollView 避免畫面溢出
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('歡迎回來', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: '密碼', border: OutlineInputBorder()),
              ),
              SizedBox(height: 24),
              // 如果正在載入，顯示進度條，否則顯示按鈕
              if (_isLoading)
                CircularProgressIndicator()
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _submitLogin, // 改用 Firebase 登入
                      child: Text('登入'),
                    ),
                    SizedBox(height: 12),
                    // Google 登入按鈕
                    ElevatedButton.icon(
                      icon: Image.asset('assets/google_logo.png', height: 24.0), // 您需要自己準備一個 Google logo 圖片
                      label: Text('使用 Google 登入'),
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterPage()),
                        );
                      },
                      child: Text('還沒有帳號？點我註冊'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}