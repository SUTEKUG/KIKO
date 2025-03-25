import 'package:flutter/material.dart';
import 'package:owner/screens/debuggingorders/orderscreen.dart';
//import 'package:owner/screens/menu/foodaddedmenu.dart';
import 'package:owner/screens/menu/menu_management_screen.dart';
import 'package:owner/screens/menu/menufoodpage.dart';
import 'package:owner/screens/orders/orders_screen.dart';
//import 'package:owner/screens/orders/test_order.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Restaurant Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Orders', icon: Icon(Icons.receipt_long)),
              Tab(text: 'Menu', icon: Icon(Icons.restaurant_menu)),
              //Tab(text: 'Foods', icon: Icon(Icons.restaurant_menu)),
              //Tab(text: 'Working', icon: Icon(Icons.restaurant_menu)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            //OrdersScreen(),
            OrdersScreenT(),
            //MenuManagementScreen(),
            YMenuManagementScreen(),
          ],
        ),
      ),
    );
  }
}
