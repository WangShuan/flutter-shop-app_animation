import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String prodId;
  final int qty;
  final int price;
  final String name;

  CartItem({this.id, this.prodId, this.name, this.price, this.qty});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return Platform.isIOS
                ? CupertinoAlertDialog(
                    title: const Text('警告'),
                    content: Text('是否移除商品 - $name'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                        child: Text(
                          'No',
                        ),
                      ),
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                        child: Text(
                          'Yes',
                        ),
                      ),
                    ],
                  )
                : AlertDialog(
                    title: Text(
                      '是否移除商品 - $name',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                        child: Text(
                          'No',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                        child: Text(
                          'Yes',
                        ),
                      ),
                    ],
                  );
          },
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(prodId);
      },
      key: ValueKey(id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 5, left: 15, right: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 5, left: 15, right: 15),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(name),
            subtitle: Text('NT\$ ${price}'),
            trailing: Text(
              '小計 \n \$ ${price * qty}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorLight,
              child: Text('x $qty'),
            ),
          ),
        ),
      ),
    );
  }
}
