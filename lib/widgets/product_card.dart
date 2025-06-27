import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restfoodblindbox/models/product_model.dart';
import 'package:restfoodblindbox/pages/product_detail.dart';

// 貨幣格式化工具
final formatter = NumberFormat.currency(locale: 'zh_TW', symbol: 'NT\$', decimalDigits: 0);

class ProductCard extends StatelessWidget {
  // 修改：直接接收一個 Product 物件和 storeId
  final Product product;
  final String storeId;

  const ProductCard({
    super.key,
    required this.product,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 導航到商品詳情頁，並傳遞完整的 product 物件和 storeId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
              storeId: storeId,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product.imageUrl, // 使用 product.imageUrl
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, // 使用 product.name
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description, // 使用 product.description
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatter.format(product.price), // 使用 product.price
                        style: TextStyle(fontSize: 18, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                      ),
                      // 我們可以在這裡直接加入購物車，但為了流程一致，先保留跳轉詳情頁
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          // 也可以在這裡觸發加入購物車的事件，提供更快捷的操作
                        },
                        tooltip: '加入購物車',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
