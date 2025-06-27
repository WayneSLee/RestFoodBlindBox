import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:restfoodblindbox/bloc/order/order_bloc.dart';
import 'package:restfoodblindbox/bloc/order/order_event.dart';
import 'package:restfoodblindbox/bloc/order/order_state.dart';
import 'package:restfoodblindbox/models/order_model.dart';
import 'package:restfoodblindbox/pages/order_detail_page.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 BlocProvider 來建立並提供 OrderBloc
    return BlocProvider(
      create: (context) => OrderBloc()..add(OrdersFetched()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('我的訂單'),
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading || state is OrderInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrderLoaded) {
              if (state.orders.isEmpty) {
                return const Center(child: Text('您目前沒有任何訂單'));
              }
              return ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return OrderCard(order: order);
                },
              );
            }
            if (state is OrderError) {
              return Center(child: Text('無法載入訂單: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// 用於顯示單筆訂單資訊的卡片 Widget
class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  // 根據訂單狀態回傳對應的顏色和文字
  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        label = '待取貨';
        break;
      case 'completed':
        color = Colors.blue;
        label = '已完成';
        break;
      case 'rejected':
        color = Colors.red;
        label = '已拒絕';
        break;
      default: // pending
        color = Colors.orange;
        label = '待處理';
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // 3. 點擊後，導航到訂單詳情頁面，並傳遞 order 物件
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 讓店家名稱更突出
                  Flexible(
                    child: Text(
                      order.storeName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const Divider(height: 20),
              Text(
                // 顯示訂單中的第一個商品作為代表
                '訂單內容: ${order.items.isNotEmpty ? order.items.first.name : ''}...',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy/MM/dd HH:mm').format(order.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    '總計: ${NumberFormat.currency(locale: 'zh_TW', symbol: 'NT\$', decimalDigits: 0).format(order.totalPrice)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
