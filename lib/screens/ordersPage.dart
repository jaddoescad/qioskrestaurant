import 'dart:async';
import '../screens/historyPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:restaurant_qiosk_client/widgets/errorMessage.dart';
import '../constants.dart';
import '../widgets/Loader.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../model/restaurant.dart';
import '../model/orders.dart';
import '../model/history.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audio_cache.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key key}) : super(key: key);
  static const routeName = '/Login';

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String loaderText = "Loading Orders...";
  bool loader = false;
  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text('Orders'),
    1: Text('History'),
  };
  StreamSubscription<QuerySnapshot> _orderStream;
  static AudioCache player = new AudioCache();

  @override
  void dispose() {
    print('dispose');
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
      print(restaurant.id);
      final orderModel = Provider.of<RestaurantOrders>(context);
      setState(() {
        loader = true;
      });
      Firestore.instance
          .collection('Orders')
          .where("r_id", isEqualTo: restaurant.id)
          .where('status', isEqualTo: 'preparing')
          .orderBy('date', descending: false)
          .getDocuments()
          .then((docs) {
        if (docs.documents?.isNotEmpty ?? false) {
          orderModel.addOrders(docs.documents);
        }
        setState(() {
          loader = false;
        });
        _orderStream = Firestore.instance
            .collection('Orders')
            .where("r_id", isEqualTo: restaurant.id)
            .where('status', isEqualTo: 'preparing')
            .orderBy('date', descending: false)
            .startAfter([
              docs.documents?.isNotEmpty ?? false
                  ? docs.documents.last['date']
                  : null
            ])
            .snapshots()
            .listen((onData) {
              onData.documentChanges.forEach((order) {
                if (order.type == DocumentChangeType.added) {
                  orderModel.addSingleOrder([order.document]);
                  //play sound
                  const alarmAudioPath = "music/ping.wav";
                  player.play(alarmAudioPath);


                } else if (order.type == DocumentChangeType.modified) {
                } else if (order.type == DocumentChangeType.removed) {}
              });
            });
      }).catchError((onError) {
        setState(() {
          loader = true;
        });
        showErrorDialog(context, onError.toString());
      });
    });
  }

  int sharedValue = 0;

  @override
  Widget build(BuildContext context) {
    final orderModel = Provider.of<RestaurantOrders>(context);
    // print(orderModel.orders);

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
            'Incomplete Orders',
            style: TextStyle(color: kMainColor),
          ),
          iconTheme: IconThemeData(color: kMainColor),
          brightness: Brightness.light,
          elevation: 1,
          backgroundColor: Colors.white,
        ),
        body: Container(
          padding: EdgeInsets.all(15),
          child: ListView(
            children: <Widget>[
              !(orderModel.orders.length == 0 && orderModel.orders.length < 0)
                  ? GridView.builder(

                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: orderModel.orders.length,
                      gridDelegate:
                          new SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              mainAxisSpacing: 50,
                              childAspectRatio: 1,
                              crossAxisSpacing: 30),
                      itemBuilder: (BuildContext context, int index) {
                        return ModalProgressHUD(
                          inAsyncCall: orderModel.orders[index].loading,
                          child: new GestureDetector(
                            child: Stack(
                              children: <Widget>[
                                new Container(
                                  padding: EdgeInsets.only(top: 10),
                                  color: kMainColor,
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: <Widget>[
                                      Text('Order#',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Text(
                                          '${orderModel.orders[index].orderId}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),

                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          '${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(orderModel.orders[index].date))}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 25)),
                                      Text(
                                          '\$${orderModel.orders[index].total.toStringAsFixed(2)}',
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
                                    order: orderModel.orders[index],
                                    rOrders: orderModel,
                                    prevContext: context,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      })
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class Receipt extends StatelessWidget {
  const Receipt({Key key, @required this.order, this.rOrders, this.prevContext})
      : super(key: key);

  final Order order;
  final RestaurantOrders rOrders;
  final BuildContext prevContext;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
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
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              rOrders.loadOrder(order);
              //make order on firebase complete thru cloud function
              //remove from array

              try {
                CloudFunctions cf = CloudFunctions();

                HttpsCallable callable = cf.getHttpsCallable(
                  functionName: 'completeOrder',
                );
                print(order.notificationId);
                var resp = await callable.call(<String, dynamic>{
                  'orderId': order.orderId,
                  'notification_id': order.notificationId

                  // 'uid':
                  // "uid": user.uid.toString(),
                  // "email": email,
                  // "name": name
                });

                if (resp.data.containsKey('error')) {
                  print(resp.data['error']);
                  rOrders.unloadOrder(order);

                  throw (resp.data['error']);
                } else {
                  print('success');
                  rOrders.removeOrder(order.orderId);
                }
              } catch (error) {
                rOrders.unloadOrder(order);
                showErrorDialog(prevContext, error.toString());
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.green,
                  border:
                      Border(top: BorderSide(color: Colors.grey, width: 0.5))),
              height: 50,
              child: Center(
                child: Text(
                  'Complete Order',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ]));
  }
}
