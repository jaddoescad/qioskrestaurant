import 'package:flutter/material.dart';
import '../constants.dart';

class Loader extends StatelessWidget {
  const Loader({
    Key key,
    @required this.context,
    @required this.loaderText,
  }) : super(key: key);

  final BuildContext context;
  final String loaderText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1, // has the effect of softening the shadow
                  // spreadRadius: 0, // has the effect of extending the shadow
                  // offset: Offset(
                  //   10.0, // horizontal, move right 10
                  //   10.0, // vertical, move down 10
                  // ),
                )
              ],
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0),
                  bottomLeft: const Radius.circular(20.0),
                  bottomRight: const Radius.circular(20.0))),
          constraints: BoxConstraints(minWidth: 250, maxWidth: 250),
          height: MediaQuery.of(context).size.width / 1.5,
          width: MediaQuery.of(context).size.width / 1.5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(kMainColor)),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                    loaderText,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
