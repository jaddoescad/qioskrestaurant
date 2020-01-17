import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  String generatedId;
  String itemId;
  String title;
  int quantity;
  double price;
  Map selectionTitles;

  OrderItem({
    this.generatedId,
    this.itemId,
    this.title,
    this.quantity,
    this.price,
    this.selectionTitles,
  });
}

class Order {
  String userId;
  String userName;
  String eatWhere;
  String orderId;
  String status;
  double subtotal;
  double taxes;
  double total;
  String rname;
  int date;
  bool archived;
  String notificationId;
  bool loading;

  Map<String, OrderItem> _orderItems = {};
  Map<String, OrderItem> get orderItems {
    return {..._orderItems};
  }

  Order(
      {this.userId,
      this.orderId,
      this.userName,
      this.eatWhere,
      this.status,
      this.subtotal,
      this.taxes,
      this.total,
      this.date,
      this.rname,
      this.archived,
      this.notificationId,
      this.loading = false
      });

  void addOrderItem(item) {
    final orderItem = OrderItem(
        generatedId: item['generatedId'],
        itemId: item['itemId'],
        title: item['title'],
        quantity: item['quantity'],
        price: item['price'].toDouble(),
        selectionTitles: item['selections']
        
        );
        


    _orderItems[item['generatedId']] = orderItem;
  }
}

class RestaurantOrders with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  clear() {
    _orders = [];
  }

  loadOrder(Order order) {
    order.loading = true;
    notifyListeners();
  }

    unloadOrder(Order order) {
    order.loading = false;
    notifyListeners();
  }

  removeOrder(orderId) {
    _orders.removeWhere((order) => order.orderId == orderId);
    notifyListeners();
  }

  void addOrders(List<DocumentSnapshot> orders) {
    _orders = [];
    orders.forEach((order) {
      addOrder(
        order.data['orderId'],
        order.data['userId'],
        order.data['r_name'],
        order.data,
        order.data['status'],
        order.data['subtotal'].toDouble(),
        order.data['taxes'].toDouble(),
        order.data['total'].toDouble(),
        order.data['date'],
        order.data.containsKey('archived') ? order.data['archived'] : false,
        order.data['notification_id'],
        order.data['eatingWhere'],
        order.data['name']
      );
    });
    _orders.sort((a, b) {
      return a.date.compareTo(b.date);
    });
  }

  void addSingleOrder(List<DocumentSnapshot> orders) {
    orders.forEach((order) {
      addOrder(
        order.data['orderId'],
        order.data['userId'],
        order.data['r_name'],
        order.data,
        order.data['status'],
        order.data['subtotal'].toDouble(),
        order.data['taxes'].toDouble(),
        order.data['total'].toDouble(),
        order.data['date'],
        order.data.containsKey('archived') ? order.data['archived'] : false,
        order.data['notification_id'],
        order.data['eatingWhere'],
        order.data['name']
      );
    });
    _orders.sort((a, b) {
      return a.date.compareTo(b.date);
    });
  }

  void addOrder(String orderId, userId, rname, orderJson, status, subtotal,
      taxes, total, date, archived, notificationId, eatingWhere, name) {
    final order = Order(
        orderId: orderId,
        status: status,
        subtotal: subtotal,
        taxes: taxes,
        total: total,
        date: date,
        rname: rname,
        archived: archived,
        notificationId: notificationId,
        userName: name,
        eatWhere: eatingWhere,
        );

    orderJson['items'].forEach((final key, final orderItem) {
      order.addOrderItem(orderItem);
    });

    // _orders[orderId.toString()] = order;
    // _orders.add(order);
    _orders.insert(0, order);

    notifyListeners();
  }

  void updateFirebaseData(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.data != null) {
      snapshot.data.documentChanges.forEach((diff) {
        if (diff.type == DocumentChangeType.modified) {
          snapshot.data.documents.forEach((order) {
            final orderToUpdateIndex = _orders
                .indexWhere((i) => i.orderId == order.documentID.toString());
            if (orderToUpdateIndex != null) {
              _orders[orderToUpdateIndex].status = order.data['status'];
              notifyListeners();
            }
          });
        }
      });
    }
  }
}