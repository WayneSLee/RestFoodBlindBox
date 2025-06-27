import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:restfoodblindbox/bloc/store_orders/store_orders_bloc.dart';
import 'package:restfoodblindbox/bloc/store_orders/store_orders_event.dart';
import 'package:restfoodblindbox/bloc/store_orders/store_orders_state.dart';
import 'package:restfoodblindbox/models/order_model.dart';

// 貨幣格式化工具
final currencyFormatter = NumberFormat.currency(locale: 'zh_TW', symbol: 'NT\$', decimalDigits: 0);
// 日期格式化工具
final dateFormatter = DateFormat('yyyy/MM/dd HH:mm');

class StoreOrdersPage extends StatelessWidget {
  final String storeId;
  const StoreOrdersPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoreOrdersBloc()..add(StoreOrdersFetched(storeId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('訂單管理')),
        body: BlocConsumer<StoreOrdersBloc, StoreOrdersState>(
          listener: (context, state) {
            if (state is StoreOrderUpdateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('操作失敗: ${state.message}'), backgroundColor: Colors.red),
              );
            } else if (state is StoreOrderUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('訂單狀態已更新'), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            if (state is StoreOrdersLoading || state is StoreOrdersInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StoreOrdersLoaded) {
              if (state.orders.isEmpty) {
                return const Center(child: Text('目前沒有任何訂單'));
              }
              final pendingOrders = state.orders.where((o) => o.status.toLowerCase() == 'pending').toList();
              final otherOrders = state.orders.where((o) => o.status.toLowerCase() != 'pending').toList();

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<StoreOrdersBloc>().add(StoreOrdersFetched(storeId));
                },
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    if(pendingOrders.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text('新進訂單', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      ...pendingOrders.map((order) => IncomingOrderCard(order: order)),
                      const Divider(height: 32, indent: 16, endIndent: 16),
                    ],
                    if(otherOrders.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16,0,16,16),
                        child: Text('歷史訂單', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      ...otherOrders.map((order) => OrderHistoryCard(order: order)),
                    ]
                  ],
                ),
              );
            }
            if (state is StoreOrdersError) {
              return Center(child: Text('無法載入訂單: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// 用於顯示「新進訂單」的卡片 Widget
class IncomingOrderCard extends StatelessWidget {
  final Order order;
  const IncomingOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // 安全地處理訂單 ID 的顯示
    final displayOrderId = order.id.length > 6 ? '${order.id.substring(0, 6)}...' : order.id;

    return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '訂單 #$displayOrderId',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])
                  ),
                  Text(
                      dateFormatter.format(order.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)
                  ),
                ],
              ),
              const Divider(height: 24),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text('${item.name} x ${item.quantity}', overflow: TextOverflow.ellipsis)),
                    Text(currencyFormatter.format(item.price * item.quantity)),
                  ],
                ),
              )).toList(),
              const Divider(height: 24),
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('總計: ', style: TextStyle(fontSize: 16)),
                    Text(
                        currencyFormatter.format(order.totalPrice),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                  ]
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('拒絕'),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('確認拒絕訂單'),
                              content: const Text('您確定要拒絕這筆訂單嗎？'),
                              actions: [
                                TextButton(child: const Text('取消'), onPressed: () => Navigator.of(ctx).pop()),
                                TextButton(
                                    child: const Text('確定拒絕', style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      context.read<StoreOrdersBloc>().add(StoreOrderRejected(order.id));
                                    }
                                ),
                              ],
                            )
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('接受'),
                      onPressed: () {
                        context.read<StoreOrdersBloc>().add(StoreOrderAccepted(order.id));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
}

/// 用於顯示「歷史訂單」的卡片 Widget
class OrderHistoryCard extends StatelessWidget {
  final Order order;
  const OrderHistoryCard({super.key, required this.order});

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String label;
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.blue;
        label = '已完成';
        break;
      case 'rejected':
        chipColor = Colors.red;
        label = '已拒絕';
        break;
      case 'accepted':
        chipColor = Colors.green;
        label = '待取貨';
        break;
      default:
        chipColor = Colors.grey;
        label = status;
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 安全地處理訂單 ID 的顯示
    final displayOrderId = order.id.length > 6 ? '${order.id.substring(0, 6)}...' : order.id;

    return Card(
        color: Colors.white,
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          title: Text('訂單 #$displayOrderId'),
          subtitle: Text('總計: ${currencyFormatter.format(order.totalPrice)}'),
          trailing: _buildStatusChip(order.status),
        )
    );
  }
}
