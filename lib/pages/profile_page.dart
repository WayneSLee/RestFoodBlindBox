import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:restfoodblindbox/pages/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 從 FirebaseAuth 獲取當前使用者
    final User? user = FirebaseAuth.instance.currentUser;

    // 登出功能的邏輯
    Future<void> signOut() async {
      try {
        // 先登出 Firebase
        await FirebaseAuth.instance.signOut();
        // 如果是使用 Google 登入，也建議一併登出 Google 帳號
        await GoogleSignIn().signOut();

        // 登出成功後，導回登入頁面並清除所有舊的頁面堆疊
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false, // 這個條件會移除所有先前的 route
          );
        }
      } catch (e) {
        // 可選：處理登出錯誤
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登出失敗: ${e.toString()}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的帳戶'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut,
            tooltip: '登出',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 2. 顯示使用者頭像 (如果有的話)
              if (user?.photoURL != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user!.photoURL!),
                )
              else
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              const SizedBox(height: 16),
              // 3. 顯示使用者名稱和 Email
              Text(
                user?.displayName ?? '使用者',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '未提供 Email',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: signOut,
                child: const Text('登出'),
              )
            ],
          ),
        ),
      ),
    );
  }
}