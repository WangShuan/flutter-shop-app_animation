import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './cart_screen.dart';

import '../models/cart.dart';
import '../models/order.dart';

import '../widgets/add_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的訂單'),
        actions: [
          Consumer<Cart>(
            builder: (context, cart, ch) => MyBadge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  CartScreen.routeName,
                );
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          } else {
            if (snapshot.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Something wrong...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                      child: Text('嘗試重新登入'),
                    )
                  ],
                ),
              );
            } else {
              return Consumer<Orders>(
                builder: (context, ordersData, child) {
                  return ordersData.orders.length == 0
                      ? Center(
                          child: Text(
                            '- 沒有訂單記錄 -',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemBuilder: (context, index) {
                            return OrderItem(ordersData.orders[index]);
                          },
                          itemCount: ordersData.orders.length,
                        );
                },
              );
            }
          }
        },
      ),
    );
  }
}
