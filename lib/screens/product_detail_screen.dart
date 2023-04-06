import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './cart_screen.dart';

import '../models/cart.dart';
import '../models/products.dart';
import '../models/auth.dart';

import '../widgets/badge.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final prodId = ModalRoute.of(context).settings.arguments as String;
    final product = Provider.of<Products>(context, listen: false).findById(prodId);
    final token = Provider.of<Products>(context, listen: false).authToken;
    final userId = Provider.of<Auth>(context, listen: false).userId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(product.name),
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
      body: Container(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 360,
                width: double.infinity,
                child: Hero(
                  tag: product.id,
                  child: Image.network(
                    product.imgUrl,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NT\$ ${(product.price).toString()}',
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<Cart>(context, listen: false)
                          .addItem(product.id, product.name, product.price);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${product.name} 成功加入購物車'),
                        action: SnackBarAction(
                          label: '復原',
                          textColor: Theme.of(context).primaryColorLight,
                          onPressed: () {
                            Provider.of<Cart>(context, listen: false).removeSingleItem(prodId);
                          },
                        ),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_rounded,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text(
                            '購買',
                            style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Consumer<Product>(
                    builder: (context, value, child) => IconButton(
                      onPressed: () {
                        setState(() {
                          product.toggleFavoriteStatus(token, userId);
                        });
                      },
                      iconSize: 30,
                      icon: Icon(
                        product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                color: Theme.of(context).primaryColor,
                width: double.infinity,
                child: const Text(
                  '商品描述',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).primaryColorLight.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Text(
                  '${product.description}',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
