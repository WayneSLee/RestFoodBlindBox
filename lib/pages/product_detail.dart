import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:restfoodblindbox/bloc/cart/cart_bloc.dart';
import 'package:restfoodblindbox/bloc/cart/cart_event.dart';
import 'package:restfoodblindbox/models/product_model.dart';

final formatter = NumberFormat.currency(locale: 'zh_TW', symbol: 'NT\$', decimalDigits: 0);

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final String storeId;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.storeId,
  });

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  double get _totalPrice => widget.product.price * _quantity;

  @override
  Widget build(BuildContext context) {
    final bool isSoldOut = widget.product.quantity <= 0;

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // 增加底部空間以防按鈕遮擋
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // 讓內容水平展開
              children: [
                // 1. 修正圖片載入錯誤
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  // 使用 Image.network 的 errorBuilder 來優雅地處理錯誤
                  child: Image.network(
                    widget.product.imageUrl,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 如果圖片載入失敗，就顯示一個預設的圖示
                      return Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: const Icon(Icons.storefront, size: 100, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                    widget.product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                Text(
                    formatter.format(widget.product.price),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Colors.grey[800])
                ),
                const SizedBox(height: 16),
                Text(
                    widget.product.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.5)
                ),
                const SizedBox(height: 24),
                Text(
                  isSoldOut ? '已售完' : '僅剩 ${widget.product.quantity} 件',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSoldOut ? Colors.red : Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 20)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: !isSoldOut && _quantity < widget.product.quantity
                          ? () => setState(() => _quantity++)
                          : null,
                    ),
                  ],
                ),
                Text(
                    formatter.format(_totalPrice),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          // 2. 修正底部按鈕
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).scaffoldBackgroundColor, // 與背景色一致
              child: ElevatedButton(
                onPressed: isSoldOut ? null : () {
                  context.read<CartBloc>().add(CartItemAdded(widget.product, widget.storeId, quantity: _quantity));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已加入購物車'), duration: Duration(seconds: 1)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSoldOut ? Colors.grey : Colors.deepPurple,
                  foregroundColor: Colors.white, // 明確設定文字和圖示顏色為白色
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // 使用 Row 來作為 child，手動控制佈局
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_checkout),
                    const SizedBox(width: 8),
                    Text(isSoldOut ? '已售完' : '加入 $_quantity 項到購物車'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
