import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restfoodblindbox/bloc/store/store_bloc.dart';
import 'package:restfoodblindbox/pages/cart.dart';
import 'package:restfoodblindbox/pages/my_orders_page.dart'; 
import 'package:restfoodblindbox/pages/profile_page.dart';
import 'package:restfoodblindbox/pages/store_list_page.dart';
import 'package:badges/badges.dart' as badges;
import 'package:restfoodblindbox/bloc/cart/cart_bloc.dart';
import 'package:restfoodblindbox/bloc/cart/cart_state.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    // 第 0 個分頁：店家列表
    BlocProvider(
      create: (context) => StoreBloc(),
      child: const StoreListPage(),
    ),
    // 第 1 個分頁：我的訂單
    const MyOrdersPage(), // 2. 將訂單頁面加入列表
    // 第 2 個分頁：購物車
    const CartPage(),
    // 第 3 個分頁：個人檔案
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          final int cartItemCount = (cartState is CartLoaded) ? cartState.items.length : 0;
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // 讓四個項目能正確顯示
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(Icons.storefront),
                label: '店家',
              ),
              // 3. 新增訂單的導覽項目
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: '訂單',
              ),
              BottomNavigationBarItem(
                icon: badges.Badge(
                  showBadge: cartItemCount > 0,
                  badgeContent: Text(
                    cartItemCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: const Icon(Icons.shopping_cart),
                ),
                label: '購物車',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '我的',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
          );
        },
      ),
    );
  }
}
