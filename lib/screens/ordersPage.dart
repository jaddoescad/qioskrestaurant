import 'dart:async';

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
import 'package:cloud_functions/cloud_functions.dart';

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

  @override
  void dispose() {
    // TODO: implement dispose
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
                } else if (order.type == DocumentChangeType.modified) {
                } else if (order.type == DocumentChangeType.removed) {}
              });
            });
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
      child: 
      
      Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: !(orderModel.orders.length == 0) ? GridView.builder(
            shrinkWrap: true,
            itemCount: orderModel.orders.length,
            gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 100,
                // crossAxisSpacing: 100
                ),
            itemBuilder: (BuildContext context, int index) {
              return new GestureDetector(
                child: new Container(
                  // height: 100,
                  // width: 100,
                  alignment: Alignment.center,
                  child: new Text('Item ${orderModel.orders[index].orderId}'),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: Receipt(order: orderModel.orders[index]),
                    ),
                  );
                },
              );
            },
          ): Container(),
        ),
      ),
    );
  }
}

class Receipt extends StatelessWidget {
  const Receipt({
    Key key,
    @required this.order,
  }) : super(key: key);

  final Order order;

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
              // Navigator.pop(context);
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

                  throw (resp.data['error']);
                } else {
                  print('success');
                  final orderModel = Provider.of<RestaurantOrders>(context);
                  orderModel.removeOrder(order.orderId);
                  // Navigator.pop(context);

                  //remove from array
                  // userProvider.changeUID(
                  //     resp.data['user']['uid'],
                  //     resp.data['user']['name'],
                  //     resp.data['user']['email'],
                  //     resp.data['user']['stripeId']);
                }
              } catch (error) {
                showErrorDialog(context, error.toString());
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