import 'dart:convert';

// 將 JSON 字串轉換為 Store 列表的輔助函式
List<Store> storeFromJson(String str) => List<Store>.from(json.decode(str).map((x) => Store.fromJson(x)));

class Store {
  final String id;
  final String name;
  final String address;
  final String category;
  final String description;
  final double rating;
  final String imageUrl;
  final String googleMapsUrl;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.description,
    required this.rating,
    required this.imageUrl,
    required this.googleMapsUrl,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json["id"],
    name: json["name"],
    address: json["address"],
    category: json["category"],
    description: json["description"],
    rating: json["rating"].toDouble(),
    imageUrl: json["imageUrl"],
    googleMapsUrl: json["googleMapsUrl"],
  );
}