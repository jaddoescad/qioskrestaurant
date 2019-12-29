import 'package:flutter/material.dart';
import '../constants.dart';

void showSuccessDialog(context, e) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          title: new Text(
            "Success",
            // textAlign: TextAlign.center,
            style: TextStyle(),
          ),
          content: new Text(e.toString()),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            Center(
              child: new FlatButton(
                child: new Text(
                  "Close",
                  style: TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      });
}

// Future<Null> showErrorDialog(context, e) async {
//   return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           elevation: 0,
//           title: new Text("Error"),
//           content: new Text(e.toString()),
//           actions: <Widget>[
//             // usually buttons at the bottom of the dialog
//             new FlatButton(
//               child: new Text("Close"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       });
// }

Future<Null> showErrorDialog(context, e) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
    title: Text("Error"),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0)), //this right here
    content: Container(
      child: Text(
              e, textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18, color: kMainColor),
            ),
    ),
    actions: <Widget> [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Dismiss',
                    style: TextStyle(color: kMainColor, fontSize: 18.0),
                  )),
            ],
          );
      });
}

