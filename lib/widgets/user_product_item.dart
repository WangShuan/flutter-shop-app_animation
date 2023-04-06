import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';

import '../models/products.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imgUrl;
  final int price;
  final String id;
  const UserProductItem({Key key, this.imgUrl, this.title, this.price, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 60,
          child: Image.network(
            imgUrl,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
        subtitle: Text('NT\$ $price'),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    EditProductScreen.routeName,
                    arguments: id,
                  );
                },
                icon: Icon(Icons.edit),
                color: Theme.of(context).primaryColorDark,
              ),
              IconButton(
                onPressed: () async {
                  final scaffold = ScaffoldMessenger.of(context);
                  try {
                    await Provider.of<Products>(context, listen: false).removeProduct(id);
                  } catch (err) {
                    scaffold.showSnackBar(SnackBar(
                      content: const Text('刪除失敗'),
                    ));
                  }
                },
                icon: Icon(Icons.delete),
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
