import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_shop_app/helpers/custom_route.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

import '../models/cart.dart';
import '../models/order.dart';
import '../models/products.dart';
import '../models/auth.dart';

Future<void> main() async {
  initializeDateFormatting('zh_TW', null);
  await dotenv.load(fileName: "assets/.env");
  runApp(MyApp());
}

var myThemeData = ThemeData(
  fontFamily: 'Lato',
  textTheme: TextTheme(
    titleSmall: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 15,
    ),
    titleMedium: TextStyle(
      color: Colors.deepPurple[700],
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: Colors.deepPurple,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      height: 1.75,
    ),
    labelLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.deepPurple[700],
    ),
  ),
  primarySwatch: Colors.deepPurple,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.deepPurple,
  ).copyWith(
    error: Colors.red[900],
  ),
  snackBarTheme: SnackBarThemeData(
    contentTextStyle: TextStyle(fontSize: 16),
    actionTextColor: Colors.deepPurple[300],
    behavior: SnackBarBehavior.floating,
  ),
  pageTransitionsTheme: PageTransitionsTheme(builders: {
    TargetPlatform.android: CustomPageTransitionsBuilder(),
    TargetPlatform.iOS: CustomPageTransitionsBuilder(),
  }),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products(null, null, []),
          update: (ctx, auth, previous) =>
              Products(auth.token, auth.userId, previous == null ? [] : previous.items),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Product(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(null, null, []),
          update: (ctx, auth, previous) =>
              Orders(auth.token, auth.userId, previous == null ? [] : previous.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, child) => auth.isAuth
            ? MaterialApp(
                title: 'Fake Shop',
                theme: myThemeData,
                home: ProductsOverviewScreen(),
                routes: {
                  ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
                  CartScreen.routeName: (context) => CartScreen(),
                  OrdersScreen.routeName: (context) => OrdersScreen(),
                  UserProductsScreen.routeName: (context) => UserProductsScreen(),
                  EditProductScreen.routeName: (context) => EditProductScreen(),
                },
              )
            : MaterialApp(
                title: 'Fake Shop',
                theme: myThemeData,
                home: FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const LinearProgressIndicator()
                          : AuthScreen(),
                ),
              ),
      ),
    );
  }
}
