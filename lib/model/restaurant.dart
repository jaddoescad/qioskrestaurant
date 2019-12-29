import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class Restaurant extends ChangeNotifier {
  String id;
  String email;

  // Restaurant({this.id, this.title});

  void setRestaurant(_id, _title) {
    this.id = _id;
    this.email = email;
  }

  void clear() {
    id = null;
    email = null;
  }
}
