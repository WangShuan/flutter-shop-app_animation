# flutter-shop-app_animation

## 製作動畫效果

### 通過 `addListener()` 搭配 `setState()` 自定義動畫
  1. 將要使用到動畫的小部件改為有狀態小部件，通過 `with` 關鍵字得到 `SingleTickerProviderStateMixin` 的方法
  2. 建立一個 `AnimationController` 類型的變量管理動畫，再建立一個 `Animation` 對象設置動畫
  3. 使用 `AnimationController()` 方法傳入參數1 vsync 對象(vsync 對象用於阻止當前畫面以外的動畫消耗資源)，參數2 duration(設置動畫執行的時間)
  4. 使用 `Tween` 自定義動畫的開始值與結束值(默認的 `Animation` 對象開始到結束為 0 到 1)
  5. 為動畫增加監聽器，執行 setState 以進行畫面變更
  6. 在要使用動畫的地方傳入 `Animation` 對象的值

舉例如下：
```dart=
class _MyCardState extends State<MyCard> with SingleTickerProviderStateMixin { // 於有狀態小部件中通過 `with` 關鍵字得到 `SingleTickerProviderStateMixin` 的方法
  AnimationController _controller; // 建立管理動畫的 AnimationController 變量
  Animation<Size> _heightAnimation; // 建立動畫對象

  @override
  void initState() { // 初始化數據
    
    // 設置 vsync 對象與動畫執行的時間
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    
    _heightAnimation = Tween<Size>( // 使用 Tween 設置動畫對象的開始與結束狀態
      begin: Size(
        double.infinity,
        260,
      ),
      end: Size(
        double.infinity,
        320,
      ),
    ).animate( // 接著使用 .animate() 傳入 CurvedAnimation() 設置動畫管理者與速率
      CurvedAnimation(
        parent: _controller, // 設置動畫管理者
        curve: Curves.linear, // 設置動畫開始與結束的過場速度模式，linear 為平滑
      ),
    );
    _heightAnimation.addListener(() { // 監聽動畫
      setState(() {}); // 調用 setState 以更新畫面
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // 釋放動畫的監聽器
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: deviceSize.width * 0.75,
        height: _heightAnimation.value.height, // 設置動畫過程中的高度為高度值
        child: ...,
      ),
    );
  }
}
```

>關於釋放可以參考：
>https://stackoverflow.com/questions/59558604/why-do-we-use-the-dispose-method-in-flutter-dart-code
>(謝謝估狗大神)

### 通過 `AnimatedBuilder()` 建立動畫

以上一個例子做修改，
1. 移除 `addListener()` 監聽動畫事件
2. 移除 `dispose()` 釋放操作
3. 將需要使用動畫的小部件，用 `AnimatedBuilder()` 小部件包起來
4. `AnimatedBuilder()` 中傳入動畫對象與建構器

完整程式碼如下：
```dart=
class _MyCardState extends State<MyCard> with SingleTickerProviderStateMixin { // 於有狀態小部件中通過 `with` 關鍵字得到 `SingleTickerProviderStateMixin` 的方法
  AnimationController _controller; // 建立管理動畫的 AnimationController 變量
  Animation<Size> _heightAnimation; // 建立動畫對象

  @override
  void initState() { // 初始化數據
    
    // 設置 vsync 對象與動畫執行的時間
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    
    _heightAnimation = Tween<Size>( // 使用 Tween 設置動畫對象的開始與結束狀態
      begin: Size(
        double.infinity,
        260,
      ),
      end: Size(
        double.infinity,
        320,
      ),
    ).animate( // 接著使用 .animate() 傳入 CurvedAnimation() 設置動畫管理者與速率
      CurvedAnimation(
        parent: _controller, // 設置動畫管理者
        curve: Curves.linear, // 設置動畫開始與結束的過場速度模式，linear 為平滑
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AnimatedBuilder(
        animation: _heightAnimation,
        child: ...,
        builder: (context, child) => Container(
          width: deviceSize.width * 0.75,
          height: _heightAnimation.value.height,
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
```

### 使用 `AnimatedContainer` 小部件建立動畫

當動畫使用者為 `Container` 小部件時，可以直接用 `AnimatedContainer` 小部件取代 `Container` 小部件
其提供了 `duration` 與 `curve`  屬性可直接生成動畫效果

舉例如下：
```dart=
class _MyCardState extends State<MyCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AnimatedContainer( // 將原本的 Container 替換為 AnimatedContainer 小部件
        duration: Duration(milliseconds: 300), // 設置動畫執行的時間
        curve: Curves.easeIn, // 設置動畫開始與結束的過場速度模式
        height: _authMode == AuthMode.Login ? 260 : 320, // 設置需要動畫效果的內容
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16),
        child: ...,
      ),
    );
  }
}
```

>其他動畫小部件使用說明：
>https://docs.flutter.dev/development/ui/widgets/animation

### 幫圖片小部件設定預設圖片，載入後出現淡入淡出動畫效果

當使用 network 方式顯示圖片時，在圖片下載完成之前，可以使用 assets 資料夾中的圖片當成預設圖片，
再於圖片下載完成之後，通過淡入淡出的效果，將預設圖片替換為實際抓取的圖片網址。

原本的圖片小部件：
```dart=
child: Image.network(
  myImgUrl, // 設置圖片網址
  fit: BoxFit.contain, // 設置圖片的 fit 值
  alignment: Alignment.topCenter, // 設置圖片的對齊方式
),
```
加入淡入淡出小部件：
```dart=
child: FadeInImage.assetNetwork( // 將原本的小部件改為 FadeInImage.assetNetwork
  placeholder: 'assets/images/product-placeholder.png', // 設置 placeholder (預設顯示的圖片)
  image: myImgUrl, // 設置實際要使用的圖片網址
  fit: BoxFit.contain, // 設置圖片的 fit 值
  alignment: Alignment.topCenter, // 設置圖片的對齊方式
),
```

### 用兩個不同路由中的相同物件，在切換時顯示過場動畫

以圖片小部件為例，假設在一個商品總覽頁，點擊縮圖後可以進入商品細節頁，而商品細節頁中的縮圖將會放大，此時就可以使用 Hero 小部件完成過場動畫效果。

使用方式：
1. 在商品總覽頁中找到圖片小部件，用 Hero 小部件把圖片小部件包起來，並設置一個唯一的 tag 值
2. 在商品細節頁中找到圖片小部件，用 Hero 小部件把圖片小部件包起來，並設置商品總覽頁中的同一個 tag 值即可

```dart=
// 商品總覽頁
child: Hero(
  tag: product.id,
  child: FadeInImage.assetNetwork(
    placeholder: 'assets/images/product-placeholder.png',
    image: product.imgUrl,
    fit: BoxFit.contain,
    alignment: Alignment.topCenter,
  ),
),

// 商品細節頁
child: Hero(
  tag: product.id,
  child: Image.network(
    product.imgUrl,
    fit: BoxFit.contain,
    alignment: Alignment.topCenter,
  ),
),
```

### 路由之間的過場動畫

原本過場動畫是左右滑動切換，假設想自定義動畫為淡入淡出，則可以自行建立一個 `.dart` 檔案：
```dart=
import 'package:flutter/material.dart'; // 首先引入 material

// 1. 設置給單個路由使用
class CustomRoute extends MaterialPageRoute { // 建立一個 class 繼承 MaterialPageRoute
  CustomRoute({WidgetBuilder builder, RouteSettings settings}) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == '/') { // 判斷是否為預設頁面
      return child;
    }
    return FadeTransition( // 如為其他頁面則使用 FadeTransition
      opacity: animation, // 傳入動畫效果
      child: child,
    );
  }
}


// 2. 設置給所有路由使用
class CustomPageTransitionsBuilder extends PageTransitionsBuilder { // 建立一個 class 繼承 PageTransitionsBuilder
  @override
  Widget buildTransitions<T>( // 將 buildTransitions 設置為泛型<T>
    PageRoute route, // 取得路由
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == '/') { // 判斷是否為預設頁面
      return child;
    }
    return FadeTransition( // 如為其他頁面則使用 FadeTransition
      opacity: animation, // 傳入動畫效果
      child: child,
    );
  }
}
```

接著使用建立好的自定義動畫設定為想要的路由過場動畫的兩種方式：
```dart=
// 1. 從 onTap 之類的函數中設定單個路由的過場動畫
Navigator.of(context).pushReplacement(CustomRoute( // 使用 pushReplacement 切換路由，並傳入自定義的 CustomRoute
  builder: (ctx) => UserProductsScreen(),
));

// 2. 從 Theme 中設定所有路由的過場動畫
pageTransitionsTheme: PageTransitionsTheme(builders: {
  TargetPlatform.android: CustomPageTransitionsBuilder(), // 使用 TargetPlatform 判斷設備，並傳入自定義的 CustomPageTransitionsBuilder
  TargetPlatform.iOS: CustomPageTransitionsBuilder(), // 使用 TargetPlatform 判斷設備，並傳入自定義的 CustomPageTransitionsBuilder
})
```