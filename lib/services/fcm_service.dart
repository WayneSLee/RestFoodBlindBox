import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:restfoodblindbox/services/api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("處理一個背景訊息: ${message.messageId}");
}

class FcmService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // 初始化權限請求和 Token 獲取
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print("===== FCM Token: $fcmToken =====");
    if (fcmToken != null) {
      try {
        await ApiService.updateFcmToken(fcmToken);
      } catch (e) {
        print("更新 FCM Token 失敗: $e");
      }
    }
    // 這個方法會在 App 從「被終止」狀態，因為點擊通知而打開時被觸發
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        print("App 從終止狀態被打開，訊息: ${message.data}");
        // TODO: 根據 message.data 導航到特定頁面
      }
    });
  }

  // 👇 --- 新增：設定訊息監聽器的方法 --- 👇
  void initPushNotifications() {
    // 當 App 處於「前景」狀態時，收到通知會觸發這個監聽器
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        print('收到前景訊息!');
        print('標題: ${notification.title}');
        print('內容: ${notification.body}');

        // 在這裡，我們可以顯示一個 SnackBar 或自訂的彈窗來提示使用者
        // (這需要一個 GlobalKey<ScaffoldMessengerState>，我們先 print)
      }
    });

    // 當 App 處於「背景」但未被終止時，點擊通知會觸發這個監聽器
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App 從背景被打開，訊息: ${message.data}');
      // TODO: 根據 message.data 導航到特定頁面
    });

    // 設定背景訊息處理器
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
