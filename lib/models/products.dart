import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import './http_exception.dart';

final firebaseUrl = dotenv.env['FIREBASE_URL'];

class Products with ChangeNotifier {
  final authToken;
  final userId;

  Products(this.authToken, this.userId, this._items);
  List<Product> _items = [];
  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  bool isListEmpty(isShowOnlyFav) {
    if (isShowOnlyFav) {
      return favoriteItems.length == 0;
    } else {
      return items.length == 0;
    }
  }

  Product findById(String prodId) {
    return items.firstWhere((element) => element.id == prodId);
  }

  Future<void> getProducts([bool filterByUser = false]) async {
    var _params;
    if (filterByUser == true) {
      _params = <String, String>{
        'auth': authToken,
        'orderBy': json.encode("user_id"),
        'equalTo': json.encode(userId),
      };
    } else {
      _params = <String, String>{
        'auth': authToken,
      };
    }

    var url = Uri.https(firebaseUrl, '/products.json', _params);
    try {
      final res = await http.get(url);
      final data = json.decode(res.body) as Map<String, dynamic>;
      final List<Product> arr = [];

      if (data == null) {
        return;
      }

      Uri favsUrl = Uri.https(
        firebaseUrl,
        '/userFavorites/${userId}.json',
        {'auth': authToken},
      );
      final favsRes = await http.get(favsUrl);
      final favsData = json.decode(favsRes.body) as Map<String, dynamic>;
      data.forEach((prodId, prodData) {
        arr.insert(
          0,
          Product(
            id: prodId,
            imgUrl: prodData['imgUrl'],
            description: prodData['description'],
            name: prodData['name'],
            price: prodData['price'],
            // isFavorite: favsData == null ? false : favsData[prodId] ?? false,
            isFavorite: favsData == null
                ? false
                : favsData[prodId] != null
                    ? favsData[prodId]
                    : false,
          ),
        );
      });

      _items = arr;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addProduct(Product prod) {
    Uri url = Uri.https(firebaseUrl, '/products.json', {'auth': authToken});

    return http
        .post(url,
            body: json.encode({
              "name": prod.name,
              "description": prod.description,
              "price": prod.price,
              "imgUrl": prod.imgUrl,
              "user_id": userId
            }))
        .then((value) {
      final newProd = Product(
        name: prod.name,
        description: prod.description,
        price: prod.price,
        imgUrl: prod.imgUrl,
        id: json.decode(value.body)['name'],
      );

      _items.insert(0, newProd);
      notifyListeners();
    }).catchError((err) {
      throw err;
    });
  }

  Future<void> updateProduct(Product prod) async {
    final i = _items.indexWhere((element) => element.id == prod.id);
    if (i != -1) {
      Uri url = Uri.https(
        firebaseUrl,
        '/products/${prod.id}.json',
        {'auth': authToken},
      );
      try {
        await http.patch(
          url,
          body: json.encode({
            "name": prod.name,
            "description": prod.description,
            "price": prod.price,
            "imgUrl": prod.imgUrl,
          }),
        );
        _items[i] = prod;
        notifyListeners();
      } catch (err) {
        throw err;
      }
    }
  }

  Future<void> removeProduct(String id) async {
    Uri url = Uri.https(
      firebaseUrl,
      '/products/${id}.json',
      {'auth': authToken},
    );
    int i = _items.indexWhere((element) => element.id == id);
    Product prod = _items[i];
    _items.removeWhere((element) => element.id == id);
    notifyListeners();

    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.insert(i, prod);
      notifyListeners();
      throw HttpException('無法刪除商品');
    }
    prod = null;
  }
}

class Product with ChangeNotifier {
  final String imgUrl;
  final String id;
  final String name;
  final String description;
  final int price;
  bool isFavorite;

  Product({
    this.id,
    this.imgUrl,
    this.name,
    this.description,
    this.price,
    this.isFavorite = false,
  });

  void _setFavValue(bool newVal) {
    isFavorite = newVal;
    notifyListeners();
  }

  void toggleFavoriteStatus(String token, String userId) async {
    bool oldVal = isFavorite;

    _setFavValue(!isFavorite);

    Uri url = Uri.https(
      firebaseUrl,
      '/userFavorites/${userId}/${id}.json',
      {'auth': token},
    );
    try {
      final res = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (res.statusCode >= 400) {
        _setFavValue(oldVal);
        throw HttpException('執行操作時遇到錯誤');
      }
    } catch (err) {
      _setFavValue(oldVal);
    }
  }
}
