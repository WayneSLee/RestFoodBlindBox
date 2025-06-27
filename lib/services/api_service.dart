import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:restfoodblindbox/models/cart_model.dart';
import 'package:restfoodblindbox/models/order_model.dart';
import 'package:restfoodblindbox/models/product_model.dart';
import 'package:restfoodblindbox/models/store_model.dart';
import 'package:restfoodblindbox/models/user_profile_model.dart';
import 'package:restfoodblindbox/services/api_exceptions.dart';

class ApiService {
  static const String _baseUrl = "https://www.kuanxingtech.com.tw:5765/api";

  // 👇 --- 加入這個臨時的除錯方法 --- 👇
  static Future<String> fetchStoreOrdersRaw(String storeId) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('使用者未登入');

    final response = await http.get(
      Uri.parse('$_baseUrl/stores/$storeId/orders'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.body; // 直接回傳原始的 JSON 字串
    } else {
      throw Exception('無法載入店家訂單列表: ${response.body}');
    }
  }

  static Future<String?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }

  static Future<UserProfile> fetchUserProfile() async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('使用者未登入');

    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw UserNotFoundInApiException('在後端資料庫中找不到使用者');
    } else {
      throw Exception('無法載入使用者資料: 狀態碼 ${response.statusCode}');
    }
  }

  static Future<void> createUserProfile({required String role}) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('使用者未登入');

    final response = await http.post(
      Uri.parse('$_baseUrl/users'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'role': role}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('建立使用者資料失敗: ${response.body}');
    }
  }

  static Future<List<Store>> fetchStores() async {
    final response = await http.get(Uri.parse('$_baseUrl/stores'));
    if (response.statusCode == 200) {
      return storeFromJson(response.body);
    } else {
      throw Exception('Failed to load stores from API');
    }
  }

  static Future<List<Product>> fetchProductsByStore(String storeId) async {
    final response = await http.get(Uri.parse('$_baseUrl/stores/$storeId/products'));
    if (response.statusCode == 200) {
      return productFromJson(response.body);
    } else {
      throw Exception('Failed to load products for store $storeId');
    }
  }

  static Future<String> createStore(Map<String, dynamic> storeData) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('使用者未登入，無法建立店家');

    final response = await http.post(
      Uri.parse('$_baseUrl/stores'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(storeData),
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      final String newStoreId = responseBody['id'];
      return newStoreId;
    } else {
      throw Exception('建立店家失敗: ${response.body}');
    }
  }

  static Future<void> createProduct(String storeId, Map<String, dynamic> productData) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/stores/$storeId/products'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(productData),
    );
    if (response.statusCode != 201) {
      throw Exception('新增商品失敗: ${response.body}');
    }
  }

  static Future<void> updateProduct(int productId, Map<String, dynamic> productData) async {
    final token = await _getAuthToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/products/$productId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(productData),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('更新商品失敗: ${response.body}');
    }
  }

  static Future<void> deleteProduct(int productId) async {
    final token = await _getAuthToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/products/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('刪除商品失敗: ${response.body}');
    }
  }

  static Future<void> createOrder(String storeId, List<CartItem> cartItems) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('使用者未登入');

    final List<Map<String, dynamic>> itemsPayload = cartItems.map((item) {
      return {'productId': item.productId, 'quantity': item.quantity};
    }).toList();

    final orderPayload = {'storeId': storeId, 'items': itemsPayload};
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(orderPayload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('建立訂單失敗: ${response.body}');
    }
  }

  static Future<List<Order>> fetchMyOrders() async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('使用者未登入');

    final response = await http.get(
      Uri.parse('$_baseUrl/orders'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('無法載入訂單列表: ${response.body}');
    }
  }

  // 獲取店家的訂單列表
  static Future<List<Order>> fetchStoreOrders(String storeId) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('使用者未登入');

    final response = await http.get(
      Uri.parse('$_baseUrl/stores/$storeId/orders'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('無法載入店家訂單列表: ${response.body}');
    }
  }

  // 接受訂單
  static Future<void> acceptOrder(String orderId) async {
    final token = await _getAuthToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/orders/$orderId/accept'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('接受訂單失敗: ${response.body}');
    }
  }

  // 拒絕訂單
  static Future<void> rejectOrder(String orderId) async {
    final token = await _getAuthToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/orders/$orderId/reject'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('拒絕訂單失敗: ${response.body}');
    }
  }

  static Future<void> updateFcmToken(String fcmToken) async {
    final token = await _getAuthToken();
    if (token == null) {
      // 如果使用者尚未登入，可以先不執行或稍後再試
      print("使用者未登入，暫不更新 FCM Token");
      return;
    }

    // 後端的端點可能是 POST 或 PUT，這裡以 POST 為例
    final response = await http.post(
      Uri.parse('$_baseUrl/users/me/fcm-token'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('更新 FCM Token 失敗: ${response.body}');
    } else {
      print("FCM Token 已成功更新到後端");
    }
  }

  static Future<void> completeOrder(String orderId) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('使用者未登入');

    final response = await http.post(
      Uri.parse('$_baseUrl/orders/$orderId/complete'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('訂單核銷失敗: ${response.body}');
    }
  }
}
