import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:restfoodblindbox/models/order_model.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // 檢查訂單狀態是否為「待取貨」
    final bool showQrCode = order.status.toLowerCase() == 'accepted';

    // 貨幣和日期格式化工具
    final currencyFormatter = NumberFormat.currency(locale: 'zh_TW', symbol: 'NT\$', decimalDigits: 0);
    final dateFormatter = DateFormat('yyyy/MM/dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('訂單詳情'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 只有在「待取貨」狀態下才顯示 QR Code
            if (showQrCode)
              Center(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white, // 給 QR Code 一個白色背景以確保掃描清晰
                      padding: const EdgeInsets.all(16.0),
                      child: QrImageView(
                        data: order.id, // 將訂單的唯一 ID 作為 QR Code 的內容
                        version: QrVersions.auto,
                        size: 220.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                        '請出示此 QR Code 給店家掃描取貨',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey)
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

            // 訂單資訊卡片
            Text('店家名稱', style: TextStyle(color: Colors.grey.shade600)),
            Text(order.storeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Text('訂單編號', style: TextStyle(color: Colors.grey.shade600)),
            Text(order.id),
            const SizedBox(height: 16),

            Text('下單時間', style: TextStyle(color: Colors.grey.shade600)),
            Text(dateFormatter.format(order.createdAt)),
            const Divider(height: 32),

            const Text('訂單內容', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // 顯示所有訂單項目
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.name} x ${item.quantity}'),
                  Text(currencyFormatter.format(item.price * item.quantity)),
                ],
              ),
            )).toList(),
            const Divider(height: 32),

            // 總金額
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('總計: ', style: TextStyle(fontSize: 18)),
                Text(
                  currencyFormatter.format(order.totalPrice),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
