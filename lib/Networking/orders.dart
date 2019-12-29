import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../models/orders.dart';
// import '../models/user.dart';
// import '../models/restaurant.dart';

class OrdersNetworking {
  // final firestore = Firestore.instance;
  //  Future createOrder(
  //     orderId, cart, subtotal, taxes, total, uid, restaurantid, context, token, rname) async {
  //   final _items = {};
  //   final status = 'preparing';
  //   final date = DateTime.now().toUtc().millisecondsSinceEpoch;

  //   cart.items.forEach((final String key, final cartItem) {
  //     final _selections = {};

  //     cartItem.selectionTitles.map((final selection) {
  //       _selections[selection.id.toString()] = {
  //         'price': selection.price,
  //         'title': selection.title,
  //       };
  //     }).toList();

  //     _items[cartItem.generatedId.toString()] = {
  //       'generatedId': cartItem.generatedId,
  //       'itemId': cartItem.itemId,
  //       'title': cartItem.title,
  //       'price': cartItem.price,
  //       'quantity': cartItem.quantity,
  //       'selections': _selections,
  //     };
  //   });

  //   Map<String, dynamic> order = {
  //     'userId': uid,
  //     'orderId': orderId,
  //     'subtotal': subtotal,
  //     'taxes': taxes,
  //     'total': total,
  //     'r_id': restaurantid,
  //     'r_name': rname,
  //     'items': _items,
  //     'date': date,
  //     'status': status
  //   };
  //   await Firestore.instance
  //       .collection('Orders')
  //       .document(orderId)
  //       .setData(order);

  //   final orderModel = Provider.of<RestaurantOrders>(context);

  //   orderModel.addOrder(orderId, rname,order, status, subtotal, taxes, total, date, true);
  //   await Future.delayed(const Duration(milliseconds: 1000), () {
  //     Navigator.of(context).pop();
  //     cart.clear();
  //   });
  // }

  // void updateOrder(context) async {
    
  //   //user restaurant id and userid
  //   final user = Provider.of<User>(context);
  //   final restaurant = Provider.of<Restaurant>(context);
  //   if (user.uid != null && restaurant.id != null) {
  //   Firestore.instance
  //         .collection('Orders')
  //         .where("userId", isEqualTo: user.uid)
  //         .snapshots()
  //         .listen((onData) {
  //       onData.documents.forEach((order) {
  //         print(order.documentID);
  //       });
  //     });
  //   }
  
  // }
}
