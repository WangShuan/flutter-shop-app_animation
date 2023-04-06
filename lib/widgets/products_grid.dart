import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/products.dart';

import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavo;

  const ProductsGrid(this.showOnlyFavo);
  @override
  Widget build(BuildContext context) {
    final productList = showOnlyFavo
        ? Provider.of<Products>(context).favoriteItems
        : Provider.of<Products>(context).items;
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: productList[index],
        child: ProductItem(),
      ),
      itemCount: productList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
