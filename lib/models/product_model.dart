import 'dart:convert';

// 將 JSON 字串轉換為 Product 列表的輔助函式
List<Product> productFromJson(String str) => List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  // 讓我們也加上數量，因為新增/編輯表單有這個欄位
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.quantity,
  });

  /// 一個工廠建構子 (Factory Constructor)，用於從 JSON map 建立 Product 物件
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // 確保即使 API 回傳的 id 是 null 或字串，也能提供一個預設值或嘗試轉換
      id: json["id"] ?? 0,

      // 如果 API 回傳的 name 是 null，就給一個預設的空字串
      name: json["name"] ?? '',

      // 這是最穩健的數字處理方式：
      // 1. 先將它視為一個通用的數字型別 `num`
      // 2. 如果是 null，就給一個預設值 0
      // 3. 最後再轉換為 `double`
      price: (json["price"] as num?)?.toDouble() ?? 0.0,

      description: json["description"] ?? '',

      imageUrl: json["imageUrl"] ?? '',

      quantity: (json["quantity"] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: "$name", price: $price, quantity: $quantity)';
  }
}
