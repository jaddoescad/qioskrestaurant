import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../screens/historyPage.dart';
import '../screens/ordersPage.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  static const routeName = '/HomePage';

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin , WidgetsBindingObserver{
  CupertinoTabController tabController;


    final Map<int, Widget> icons = const <int, Widget>{
    0: OrdersPage(),
    1: HistoryPage()
  };

  int sharedValue = 0;

  @override
  void initState() {
    super.initState();
    tabController = new CupertinoTabController(initialIndex: 0);
    // OrdersNetworking
    WidgetsBinding.instance.addObserver(this);

  }

  @override
  void dispose() {
    tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
          appBar: AppBar(
            // automaticallyImplyLeading: false,
            iconTheme: IconThemeData(color: kMainColor),
            brightness: Brightness.light,
            elevation: 1,
            backgroundColor: Colors.white,
            ),

            body: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                title: Text('Home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.conversation_bubble),
                title: Text('Support'),
              ),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            assert(index >= 0 && index <= 2);
            switch (index) {
              case 0:
                return CupertinoTabView(
                  builder: (BuildContext context) {
                    return OrdersPage();
                  },
                  defaultTitle: 'Colors',
                );
                break;
              case 1:
                return CupertinoTabView(
                  builder: (BuildContext context) => HistoryPage(),
                  defaultTitle: 'Support Chat',
                );
                break;
            }
            return null;
          },
        ),
    
    
    );

  }
}
