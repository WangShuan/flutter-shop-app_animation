import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _tempProductScreenState();
}

class _tempProductScreenState extends State<EditProductScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  String _imgUrlInputed = '';
  var _tempProd = Product(
    id: null,
    name: '',
    price: 0,
    imgUrl: '',
    description: '',
  );
  var _initValues = {
    'name': '',
    'price': '',
    'imgUrl': '',
    'description': '',
  };

  void _showErrDialog(String msg) {
    showDialog<Null>(
      context: context,
      builder: (ctx) => Platform.isIOS
          ? CupertinoAlertDialog(
              title: const Text('錯誤'),
              content: Text(msg),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('確定'),
                ),
              ],
            )
          : AlertDialog(
              title: const Text(
                '錯誤',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                msg,
                style: TextStyle(color: Colors.black54),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('確定'),
                )
              ],
            ),
    );
  }

  final _form = GlobalKey<FormState>();
  void _saveForm() {
    final isValidate = _form.currentState.validate();
    if (!isValidate) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    _form.currentState.save();

    if (_tempProd.id == null) {
      Provider.of<Products>(context, listen: false).addProduct(_tempProd).catchError((err) {
        return _showErrDialog('執行操作時發生錯誤，請重試。');
      }).then((value) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    } else {
      Provider.of<Products>(context, listen: false).updateProduct(_tempProd).catchError((err) {
        return _showErrDialog('執行操作時發生錯誤，請重試。');
      }).then((value) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (ModalRoute.of(context).settings.arguments != null) {
        final prodId = ModalRoute.of(context).settings.arguments as String;
        _tempProd = Provider.of<Products>(context, listen: false).findById(prodId);
        _initValues = {
          'name': _tempProd.name,
          'price': _tempProd.price.toString(),
          'imgUrl': _tempProd.imgUrl,
          'description': _tempProd.description,
        };
        _imgUrlInputed = _tempProd.imgUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增產品'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: _isLoading
          ? LinearProgressIndicator()
          : Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _initValues['name'],
                      decoration: const InputDecoration(labelText: '商品名稱'),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value.isEmpty ? '請輸入商品名稱' : null,
                      onSaved: (newValue) => _tempProd = Product(
                        id: _tempProd.id,
                        name: newValue,
                        price: _tempProd.price,
                        imgUrl: _tempProd.imgUrl,
                        description: _tempProd.description,
                        isFavorite: _tempProd.isFavorite,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: const InputDecoration(labelText: '商品價格'),
                      textInputAction: TextInputAction.next,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return '請輸入商品價格';
                        }
                        if (int.tryParse(value) == null) {
                          return '請輸入有效的數值';
                        }
                        if (int.parse(value) <= 0) {
                          return '請輸入正數金額';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _tempProd = Product(
                        id: _tempProd.id,
                        name: _tempProd.name,
                        price: int.parse(newValue),
                        imgUrl: _tempProd.imgUrl,
                        isFavorite: _tempProd.isFavorite,
                        description: _tempProd.description,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: const InputDecoration(labelText: '商品描述'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      validator: (value) => value.length < 10 ? '商品描述不得少於十個字' : null,
                      onSaved: (newValue) => _tempProd = Product(
                        id: _tempProd.id,
                        name: _tempProd.name,
                        price: _tempProd.price,
                        isFavorite: _tempProd.isFavorite,
                        imgUrl: _tempProd.imgUrl,
                        description: newValue,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues['imgUrl'],
                      decoration: const InputDecoration(labelText: '圖片連結'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value.isEmpty) {
                          return '請輸入圖片連結';
                        }
                        if (!value.startsWith('https')) {
                          return '請輸入正確的連結';
                        }
                        if (!value.endsWith('.png') &&
                            !value.endsWith('.jpg') &&
                            !value.endsWith('.jpeg')) {
                          return '請輸入正確的圖片連結';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        if (!val.startsWith('https') ||
                            (!val.endsWith('.png') &&
                                !val.endsWith('.jpg') &&
                                !val.endsWith('.jpeg'))) {
                          return;
                        }
                        setState(() {
                          _imgUrlInputed = val;
                        });
                      },
                      onSaved: (newValue) => _tempProd = Product(
                        id: _tempProd.id,
                        name: _tempProd.name,
                        price: _tempProd.price,
                        isFavorite: _tempProd.isFavorite,
                        imgUrl: newValue,
                        description: _tempProd.description,
                      ),
                      onFieldSubmitted: (val) {
                        _saveForm();
                      },
                    ),
                    Container(
                      height: 240,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      child: _imgUrlInputed.isEmpty
                          ? const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                              ),
                            )
                          : Image.network(
                              _imgUrlInputed,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
