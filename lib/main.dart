import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:restaurant_qiosk_client/screens/loginPage.dart';
import './constants.dart';
import './screens/splashScreen.dart';
import './screens/ordersPage.dart';
import './model/restaurant.dart';
import './model/orders.dart';
import './model/history.dart';



final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  // debugPaintSizeEnabled = true; //         <--- enable visual rendering
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RestaurantHistory(),
        ),
        ChangeNotifierProvider(
          create: (_) => Restaurant(),
        ),
        ChangeNotifierProvider(
          create: (_) => RestaurantOrders(),
        ),
      ],
      child: MaterialApp(
        title: 'Qiosk',
        // darkTheme: ThemeData.dark(),
        theme: ThemeData(
          fontFamily: 'Avenir',
          primaryColor: kMainColor,
        ),
        home: Splash(),
        navigatorObservers: [routeObserver],
        routes: {
          LoginPage.routeName: (ctx) => LoginPage(),
          OrdersPage.routeName: (ctx) => OrdersPage(),
        },
      ),
    );
  }
}