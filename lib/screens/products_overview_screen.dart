import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/cart_screen.dart';

import '../models/cart.dart';
import '../models/products.dart';

import '../widgets/add_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFavo = false;

  // bool _isLoading = false;

  // getProducts 使用方式 1
  // @override
  // void initState() {
  //   _isLoading = true;
  //   Provider.of<Products>(context, listen: false).getProducts().then((value) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  //   super.initState();
  // }

  // getProducts 使用方式 2
  // bool _isInit = true;
  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     Provider.of<Products>(context).getProducts().then((value) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     });
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  Future<void> _refreshProds(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('菲克商店'),
        actions: [
          PopupMenuButton(
            initialValue: _showOnlyFavo ? FilterOptions.Favorites : FilterOptions.All,
            onSelected: (FilterOptions val) {
              if (val == FilterOptions.Favorites) {
                setState(() {
                  _showOnlyFavo = true;
                });
              } else {
                setState(() {
                  _showOnlyFavo = false;
                });
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text('All Products'),
                value: FilterOptions.All,
              ),
              const PopupMenuItem(
                child: const Text('My Favorites'),
                value: FilterOptions.Favorites,
              ),
            ],
          ),
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
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _refreshProds(context),
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
              return RefreshIndicator(
                onRefresh: () => _refreshProds(context),
                child: Provider.of<Products>(context, listen: false).isListEmpty(_showOnlyFavo)
                    ? Center(
                        child: Text(
                          _showOnlyFavo ? '- 您的願望清單為空 -' : '- 目前店內沒有商品 -',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      )
                    : ProductsGrid(_showOnlyFavo),
              );
            }
          }
        },
      ),
    );
  }
}
