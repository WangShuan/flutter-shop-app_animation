import 'package:flutter/material.dart';

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  int get totalAmount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += (cartItem.price * cartItem.qty);
    });
    return total;
  }

  void addItem(String prodId, String title, int price) {
    if (_items.containsKey(prodId)) {
      _items.update(
        prodId,
        (value) => CartItem(
            id: value.id,
            name: value.name,
            price: value.price,
            qty: value.qty + 1),
      );
    } else {
      _items.putIfAbsent(
        prodId,
        () => CartItem(
          id: DateTime.now().toString(),
          name: title,
          price: price,
          qty: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String prodId) {
    _items.remove(prodId);
    notifyListeners();
  }

  void clearItems() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String prodId) {
    if (_items[prodId].qty > 1) {
      _items.update(
        prodId,
        (value) => CartItem(
            id: value.id,
            name: value.name,
            price: value.price,
            qty: value.qty - 1),
      );
    } else {
      _items.remove(prodId);
    }
    notifyListeners();
  }
}

class CartItem {
  final String id;
  final int qty;
  final int price;
  final String name;

  CartItem({
    @required this.id,
    @required this.name,
    @required this.price,
    @required this.qty,
  });
}
