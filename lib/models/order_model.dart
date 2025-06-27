import 'dart:convert';

// 將 JSON 字串轉換為 Order 列表的輔助函式
List<Order> ordersFromJson(String str) => List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));

// --- OrderItem class ---
class OrderItem {
  final int productId;
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      // 👇 --- 這是我們修正的核心之一 --- 👇
      // 處理店家端 API 沒有 productId 的情況
      productId: json['productId'] ?? 0, // 如果找不到 productId，就給一個預設值 0
      name: json['name'] ?? '商品名稱未知',
      // 處理店家端 API 的 unitPrice
      price: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
    );
  }
}

// --- Order class ---
class Order {
  final String id;
  final String storeId;
  final String storeName;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // 安全地讀取巢狀的 store 物件
    final storeData = json['store'] as Map<String, dynamic>?;

    return Order(
      id: json['id'].toString(),

      // 👇 --- 這是我們修正的核心之二 --- 👇
      // 兼容兩種情況：
      // 1. 如果有巢狀的 store 物件 (消費者端)，就從裡面讀取。
      // 2. 如果沒有 (店家端)，則安全地回傳預設值。
      storeId: storeData?['storeId']?.toString() ?? '',
      storeName: storeData?['name'] ?? '店家名稱未知',

      status: json['status'] ?? 'pending',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,

      // 兼容 orderDate 這個鍵
      createdAt: json['orderDate'] != null
          ? DateTime.tryParse(json['orderDate']) ?? DateTime.now()
          : DateTime.now(),

      items: json['items'] != null && json['items'] is List
          ? (json['items'] as List)
          .map((itemJson) => OrderItem.fromJson(itemJson))
          .toList()
          : [],
    );
  }
}
