import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';

class OrderItem extends StatefulWidget {
  final Order order;
  const OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.order.id),
      onDismissed: (direction) {
        Provider.of<Orders>(context, listen: false).removeOrder(widget.order.id);
      },
      background: Container(
        margin: const EdgeInsets.all(5),
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
        margin: const EdgeInsets.all(5),
        child: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  Text(
                    '總金額',
                    style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 18),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'NT\$ ${widget.order.amount}',
                    style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 18),
                  ),
                ],
              ),
              subtitle: Text(
                '${DateFormat("yyyy/MM/dd", 'zh_TW').format(widget.order.dateTime)} ${DateFormat("a hh:mm", 'zh_TW').format(widget.order.dateTime)}',
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: _expanded
                  ? min(
                      double.maxFinite,
                      widget.order.products.length * 90.0,
                    )
                  : 0,
              curve: Curves.easeOut,
              child: ListView.builder(
                itemBuilder: (context, index) => Column(
                  children: [
                    const Divider(),
                    ListTile(
                      title: Text(
                        widget.order.products[index].name,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        'NT\$ ${widget.order.products[index].price} x ${widget.order.products[index].qty}',
                      ),
                      trailing: Text(
                        '小計 \n \$ ${widget.order.products[index].price * widget.order.products[index].qty}',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                itemCount: widget.order.products.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
