import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restfoodblindbox/bloc/my_products/my_products_bloc.dart';
import 'package:restfoodblindbox/pages/my_products_page.dart';
import 'package:restfoodblindbox/pages/store_orders_page.dart';
import 'package:restfoodblindbox/pages/qr_scanner_page.dart';

class StoreDashboardPage extends StatelessWidget {
  final String storeId;
  const StoreDashboardPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('店家管理中心'),
        automaticallyImplyLeading: false,
      ),
      body: GridView.count(
        crossAxisCount: 2, // 每行顯示兩個項目
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: <Widget>[
          _buildDashboardCard(
            context,
            icon: Icons.fastfood,
            label: '我的商品',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) => MyProductsBloc(),
                    child: MyProductsPage(storeId: storeId),
                  ),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.receipt_long,
            label: '訂單管理',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StoreOrdersPage(storeId: storeId),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.qr_code_scanner, // 2. 新增掃描圖示
            label: '掃描核銷',
            onTap: () {
              // 3. 導航到掃描器頁面
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QrScannerPage()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.bar_chart,
            label: '銷售報告',
            onTap: () {
              // TODO: 導航到「銷售報告」頁面
              print('導航到銷售報告頁面');
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.store,
            label: '店家資訊',
            onTap: () {
              // TODO: 導航到「店家資訊」頁面
              print('導航到店家資訊頁面');
            },
          ),
        ],
      ),
    );
  }

  // 用於建立儀表板卡片的輔助方法
  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
