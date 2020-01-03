import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/Loader.dart';
import '../screens/ordersPage.dart';
import '../widgets/errorMessage.dart';
import '../Networking/Auth.dart';
import '../screens/homePage.dart';

typedef void ChangeAuthPage(String pageString);

class LoginPage extends StatefulWidget {
  static const routeName = '/Login';
  final Function changePageCallback;
  final String cameFrom;
  LoginPage({this.changePageCallback, this.cameFrom});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _LoginData _data = new _LoginData();
  bool loader = true;
  var authHandler = Auth();
  final loaderText = 'Logging In...';

  @override
  void initState() {
    super.initState();
    authHandler.checkIfUserExists(context).then((success) {
      print(success);
      if (success == true) {
        Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) => HomePage()));
        setState(() {
          loader = false;
        });
      } else {
        setState(() {
          loader = false;
        });
      }
    });
  }
  /// Normally the signin buttons should be contained in the SignInPage
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return ModalProgressHUD(
      progressIndicator: Loader(context: context, loaderText: loaderText),
      inAsyncCall: loader,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(color: kMainColor),
          brightness: Brightness.light,
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(
            "Login",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: kMainColor,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            // color: Colors.red,
            height: double.infinity,
            constraints: BoxConstraints(maxWidth: 600),
            padding: new EdgeInsets.only(left: 40.0, right: 40.0),
            child: Form(
              key: this._formKey,
              child: Theme(
                data:
                    Theme.of(context).copyWith(splashColor: Colors.transparent),
                child: new ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new TextFormField(
                            onSaved: (String value) {
                              this._data.email = value;
                            },
                            validator: this._validateEmail,
                            keyboardType: TextInputType
                                .emailAddress, // Use email input type for emails.
                            decoration: new InputDecoration(
                              fillColor: Colors.white,
                              // focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: COlors.)),
                              hintText: '',
                              labelText: 'E-mail Address',
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new TextFormField(
                          onSaved: (String value) {
                            this._data.password = value;
                          },
                          validator: this._validatePassword,
                          obscureText: true, // Use secure text for passwords.
                          decoration: new InputDecoration(
                              hintText: '', labelText: 'Enter your password')),
                    ),
                    // SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Container(
                        width: screenSize.width,
                        height: 50,
                        // color: kMainColor,
                        child: new FlatButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: new Text(
                            'Login',
                            style: new TextStyle(
                                color: Colors.white, fontSize: 17),
                          ),
                          onPressed: () {
                            submit();
                          },
                          color: kMainColor,
                        ),
                        margin: new EdgeInsets.only(top: 20.0),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _validateEmail(String value) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (!emailValid) {
      return 'The Email Address must be a valid email address.';
    }
    return null;
  }

  // Add validate password function.
  String _validatePassword(String value) {
    if (value.length < 8) {
      return 'The Password must be at least 8 characters.';
    }

    return null;
  }

  void submit() async {

    if (this._formKey.currentState.validate()) {
      setState(() {
        loader = true;
      });
      _formKey.currentState.save();

      // Save our form now.
        try {
        await authHandler
            .handleSignInEmail(_data.email, _data.password, context)
            .then((FirebaseUser user) async {
          await Future.delayed(const Duration(milliseconds: 500), (){});
          setState(() {
            loader = false;
          });

    //       print('success');
          Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) => HomePage()));

        });
        } catch (error) {
          setState(() {
            loader = false;
          });
          print(error.toString());
          //clear provider
          //signout
          showErrorDialog(context, 'There was an error an error authenticating user');
        }
      }
    }
  }


class _LoginData {
  String email = '';
  String password = '';
}