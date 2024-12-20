import 'dart:async';
import 'package:restaurant_qiosk_client/widgets/errorMessage.dart';
import '../screens/ordersPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../constants.dart';
import '../widgets/Loader.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../model/restaurant.dart';
import '../model/history.dart';
import '../model/orders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key key}) : super(key: key);
  static const routeName = '/Login';

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String loaderText = "Loading Orders...";
  StreamSubscription<QuerySnapshot> _orderStream;
  int latestTime;
  bool loadingMoreOrder = false;
  bool loader = false;

  @override
  void dispose() {
    // TODO: implement dispose
    if (_orderStream != null) {
      _orderStream.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final restaurant = Provider.of<Restaurant>(context);
      final historyModel = Provider.of<RestaurantHistory>(context);
      final now = DateTime.now();
      final lastMidnight = new DateTime(now.year, now.month, now.day)
          .toUtc()
          .millisecondsSinceEpoch;
      final midnight = new DateTime(now.year, now.month, now.day + 1)
          .toUtc()
          .millisecondsSinceEpoch;
      setState(() {
        loader = true;
      });
      Firestore.instance
          .collection('Orders')
          .where("r_id", isEqualTo: restaurant.id)
          .where('status', isEqualTo: 'complete')
          .orderBy('date', descending: true)
          .startAt([midnight])
          .endAt([lastMidnight])
          .limit(25)
          .getDocuments()
          .then((docs) {
            historyModel.addOrders(docs.documents);
            setState(() {
              loader = false;
            });
          })
          .catchError((onError) {
            setState(() {
              loader = false;
            });
            showErrorDialog(context, 'Error Loading Orders');
          });
    });
  }

  int sharedValue = 0;

  @override
  Widget build(BuildContext context) {
    final orderHistory = Provider.of<RestaurantHistory>(context);
    print(orderHistory.orders);
    final restaurant = Provider.of<Restaurant>(context);
    final now = DateTime.now();

    final lastMidnight = new DateTime(now.year, now.month, now.day)
        .toUtc()
        .millisecondsSinceEpoch;
    return ModalProgressHUD(
      progressIndicator: Loader(context: context, loaderText: loaderText),
      inAsyncCall: loader,
      child: Scaffold(
          drawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text("Les Moulins La Fayette"),
                  accountEmail: Text("lmlfqiosk@gmail.com"),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? Colors.blue
                            : Colors.white,
                    child: Text(
                      "LM",
                      style: TextStyle(color: Colors.black, fontSize: 40.0),
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Incomplete Orders'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(builder: (ctx) => OrdersPage()));
                  },
                ),
                ListTile(
                  title: Text('Orders Completed Today'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(builder: (ctx) => HistoryPage()));
                  },
                ),
                ListTile(
                  title: Text('Sign Out'),
                  onTap: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      final history = Provider.of<RestaurantHistory>(context);
                      final orders = Provider.of<RestaurantOrders>(context);
                      final restaurant = Provider.of<Restaurant>(context);
                      history.clear();
                      orders.clear();
                      restaurant.clear();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } catch (error) {
                      print(error);
                      showErrorDialog(context, 'Sign Out Was Not Successful');
                    }
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            // automaticallyImplyLeading: false,
            title: Text(
              'Orders Completed Today',
              style: TextStyle(color: kMainColor),
            ),
            iconTheme: IconThemeData(color: kMainColor),
            brightness: Brightness.light,
            elevation: 1,
            backgroundColor: Colors.white,
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.pixels ==
                  scrollNotification.metrics.maxScrollExtent) {
                if (loadingMoreOrder == false) {
                  loadingMoreOrder = true;
                  Firestore.instance
                      .collection('Orders')
                      .where("r_id", isEqualTo: restaurant.id)
                      .where('archived', isEqualTo: false)
                      .orderBy('date', descending: true)
                      .startAfter([latestTime])
                      .endAt([lastMidnight])
                      .limit(5)
                      .getDocuments()
                      .then((docs) {
                        docs.documents.forEach((order) {
                          // if (order.type == DocumentChangeType.added) {
                          latestTime = order.data['date'];
                          orderHistory.addSingleOrder([order]);
                        });
                        loadingMoreOrder = false;
                        // orderHistory.addOrders(docs.documents);
                        //  setState(() {
                        //     items_number += 10 ;
                        //  });
                      });
                }
              }
            },
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 10, left: 20, bottom: 10),
                  color: kMainColor,
                  // height: 50.0,
                  child: Text(
                    'Today',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                !(orderHistory.orders.length == 0)
                    ? Container(
                        padding: EdgeInsets.all(15),
                        child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: orderHistory.orders.length,
                            gridDelegate:
                                new SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 200,
                                    mainAxisSpacing: 50,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 30),
                            itemBuilder: (BuildContext context, int index) {
                              return new GestureDetector(
                                child: Stack(
                                  children: <Widget>[
                                    new Container(
                                      padding: EdgeInsets.only(top: 10),
                                      color: kMainColor,
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: <Widget>[
                                          Text('Order#',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          Text(
                                              '${orderHistory.orders[index].orderId}',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),

                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                              '${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(orderHistory.orders[index].date))}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 25)),
                                          Text(
                                              '\$${orderHistory.orders[index].total.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15)),
                                        ],
                                      ),
                                    )
                                    // Center(
                                    //   child: Text(
                                    //       '\$${orderModel.orders[index].total.toStringAsFixed(2)}',
                                    //       style: TextStyle(
                                    //           color: Colors.white,
                                    //           fontWeight: FontWeight.w800,
                                    //           fontSize: 25)),
                                    // )
                                  ],
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      child: Receipt(
                                          order: orderHistory.orders[index]),
                                    ),
                                  );
                                },
                              );
                            }),
                      )
                    : Container(),
              ],
            ),
          )),
    );
  }
}

class Receipt extends StatelessWidget {
  const Receipt({
    Key key,
    @required this.order,
  }) : super(key: key);

  final History order;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.grey,
                border:
                    Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
            height: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(top: BorderSide(color: Colors.grey, width: 3))),
                height: 50,
                child: Center(
                  child: Text(
                    'Close',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Order #" + order.orderId,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                                order.orderItems.keys
                                    .toString()
                                    .substring(1, 11),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                    color: Colors.grey)),
                            Text(order.rname,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: kMainColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ...order.orderItems.values.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Container(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            " " +
                                                item.quantity.toString() +
                                                "  " +
                                                item.title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: kMainColor),
                                          ),
                                          ...item.selectionTitles.values
                                              .map((selection) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16.0),
                                              child: Text(
                                                selection['title'],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                            );
                                          }),
                                        ]),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Subtotal"),
                                    Text(
                                        '\$ ${order.subtotal.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Taxes"),
                                    Text(
                                        '\$ ${order.taxes.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Total",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('\$ ${order.total.toStringAsFixed(2)}'),
                                ],
                              ),
                            ]),
                      ),
                    ]),
              ),
            ),
          ),
        ]));
  }
}
