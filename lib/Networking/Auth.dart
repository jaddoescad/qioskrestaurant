import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/restaurant.dart';
// import '../models/user.dart';
import 'package:cloud_functions/cloud_functions.dart';
// import '../models/payment.dart';
// import '../Networking/Restaurant.dart';
// import '../models/restaurant.dart';
// import '../models/orders.dart';

class Auth with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<FirebaseUser> handleSignInEmail(
      String email, String password, context) async {
    AuthResult result =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    final FirebaseUser user = result.user;
          final restaurant = Provider.of<Restaurant>(context);

    assert(user != null);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await auth.currentUser();
    assert(user.uid == currentUser.uid);
    print('signInEmail succeeded: $user');

    final restaurantDoc = await Firestore.instance
        .collection('Restaurants')
        .where("email", isEqualTo: user.email)
        .getDocuments();

    
    if (restaurantDoc.documents.isNotEmpty) {
          restaurant.setRestaurant(restaurantDoc.documents[0].documentID, user.email);

    } else {
      await FirebaseAuth.instance.signOut();
      restaurant.clear();
      throw('could not find restaurant');
    }

    //get restaurnt info from email

    //if they dont exist assert

    //set restaurant provider

    return user;
  }

  // Future<bool> getOrders(context, user, restaurant, restaurantOrders) async {
  //   final data =
  //       await RestaurantNetworking.fetchOrders(restaurant.id, user.uid);
  //   restaurantOrders.addOrders(data);
  //   return true;
  // }

  // Future<void> sendPasswordResetEmail(String email) async {
  //   return auth.sendPasswordResetEmail(email: email);
  // }

  // Future handleSignUp(email, password, context, name) async {
  //   AuthResult result = await auth.createUserWithEmailAndPassword(
  //       email: email, password: password);

  //   final userProvider = Provider.of<User>(context);
  //   final FirebaseUser user = result.user;
  //   assert(user != null);
  //   assert(await user.getIdToken() != null);
  //   CloudFunctions cf = CloudFunctions();
  //   HttpsCallable callable = cf.getHttpsCallable(
  //     functionName: 'createUserAccount',
  //   );
  //   var resp = await callable.call(<String, dynamic>{
  //     "uid": user.uid.toString(),
  //     "email": email,
  //     "name": name
  //   });

  //   if (resp.data.containsKey('error')) {
  //     print("error");

  //     throw (resp.data['error']);
  //   } else {
  //     print(resp.data['user']['uid']);
  //     userProvider.changeUID(
  //         resp.data['user']['uid'],
  //         resp.data['user']['name'],
  //         resp.data['user']['email'],
  //         resp.data['user']['stripeId']);
  //   }
  // }

  // Future checkIfUserExists(context) async {
  //   await FirebaseAuth.instance.currentUser().then((firebaseUser) async {
  //     if (firebaseUser != null) {
  //       var document = await Firestore.instance
  //           .collection('Users')
  //           .document(firebaseUser.uid.toString())
  //           .get();
  //       final userProvider = Provider.of<User>(context);
  //       final payment = Provider.of<PaymentModel>(context);
  //       userProvider.changeUID(document['uid'], document['name'],
  //           document['email'], document['stripe_id']);
  //       if (document.data.containsKey('source')) {
  //         final source = document['source'];
  //         payment.setCard(
  //             source['id'], source['card']['last4'], source['card']['brand']);
  //         //get orders
  //       }
  //     }
  //   });
  // }
}
