import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bookaslot2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'gmailuserlist.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  runApp(MaterialApp(
      home: email == null
          ? MyApp()
          : bookaslot2(
              username: email,
            )));
  SharedPreferences prefs2 = await SharedPreferences.getInstance();
  var admin_email = prefs2.getString('admin_email');
  runApp(MaterialApp(
      home: admin_email == null
          ? MyApp()
          : gmailuserlist(
              adminEmail: admin_email,
            )));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _Myhomepagestate createState() => _Myhomepagestate();
}

class _Myhomepagestate extends State<MyHomePage> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<FirebaseUser> googlesignin() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    if (user.email == "chnsag4app@gmail.com") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('admin_email', user.email);
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        duration: new Duration(seconds: 4),
        content: new Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text("  Signing-In...")
          ],
        ),
      ));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => gmailuserlist(
                    adminEmail: "chnsag4app@gmail.com",
                  )));
    } else {
      Future<bool> ret1() async {
        QuerySnapshot g = await Firestore.instance
            .collection('Gmailuserlist')
            .where('Email', isGreaterThan: '')
            .getDocuments();
        bool i1 = false;
        var d = g.documents;
        for (int j = 0; j < g.documents.length; j++) {
          if (user.email == d[j]['Email'].toString()) {
            i1 = true;
          }
        }
        return i1;
      }

      bool gmailcheck = await ret1();

      if (gmailcheck == true) {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          duration: new Duration(seconds: 4),
          content: new Row(
            children: <Widget>[
              new CircularProgressIndicator(),
              new Text("  Signing-In...")
            ],
          ),
        ));
        try {
          Future<bool> ret() async {
            QuerySnapshot q = await Firestore.instance
                .collection('ParkingDB')
                .where('Email', isGreaterThan: '')
                .getDocuments();
            bool i1 = false;
            var d = q.documents;
            for (int j = 0; j < q.documents.length; j++) {
              if (user.email == d[j]['Email'].toString()) {
                i1 = true;
              }
            }
            return i1;
          }

          bool j = await ret();
          if (!j) {
            Firestore.instance
                .collection("ParkingDB")
                .document()
                .setData({'Email': user.email});
            print('User added to the database');
          }
          if (user != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('email', user.email);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => bookaslot2(
                          username: user.email,
                        )));
          }
        } catch (e) {
          print(e);
        }
        return user;
      } else {
        Flushbar(
          padding: EdgeInsets.all(10),
          borderRadius: 8,
          backgroundColor: Colors.blue,
          boxShadows: [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(3, 3),
              blurRadius: 3,
            ),
          ],
          duration: new Duration(seconds: 4),
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
          leftBarIndicatorColor: Colors.red,
          forwardAnimationCurve: Curves.easeInOutCubic,
          title: "Sorry! Invalid Access",
          message: "Your Gmail is not authorized to login",
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(
            Icons.warning,
            color: Colors.red,
          ),
        ).show(context);
      }
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String un;
  String pw;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("APP_STATE: $state");

    if (state == AppLifecycleState.resumed) {
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
    } else if (state == AppLifecycleState.paused) {
      // user quit our app temporally
    }
  }

  var _u = new TextEditingController();
  var _p = new TextEditingController();

  Widget _email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFF6CA8F1),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            controller: _u,
            validator: (val) => val.isEmpty ? 'Email cannot be empty' : null,
            onSaved: (val) => un = val,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your Email',
              hintStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Varela',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _password() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFF6CA8F1),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            controller: _p,
            validator: (val) => val.isEmpty ? 'Password cannot be empty' : null,
            onSaved: (val) => pw = val,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your Password',
              hintStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Varela',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginbutton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => signin(),
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  Widget _extratext() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Varela',
          ),
        ),
      ],
    );
  }

  Widget _socialicon(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _iconrow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _socialicon(
            () => googlesignin(),
            AssetImage(
              'assets/images/gimage.png',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF73AEF5),
                        Color(0xFFFFFFFF),
                        Color(0xFF478DE0),
                        Color(0xFF398AE5),
                      ],
                      stops: [0.1, 0.4, 0.7, 0.9],
                    ),
                  ),
                ),
                Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 120.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Office Park',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Pacifico',
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 30.0),
                        _email(),
                        SizedBox(
                          height: 30.0,
                        ),
                        _password(),
                        _loginbutton(),
                        _extratext(),
                        _iconrow(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signin() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: un, password: pw);
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          duration: new Duration(seconds: 4),
          content: new Row(
            children: <Widget>[
              new CircularProgressIndicator(),
              new Text("  Signing-In...")
            ],
          ),
        ));
        Future<bool> ret() async {
          QuerySnapshot q = await Firestore.instance
              .collection('ParkingDB')
              .where('Email', isGreaterThan: '')
              .getDocuments();
          bool i1 = false;
          var d = q.documents;
          for (int j = 0; j < q.documents.length; j++) {
            if (un == d[j]['Email'].toString()) {
              i1 = true;
            }
          }
          return i1;
        }

        bool j = await ret();
        if (!j) {
          Firestore.instance
              .collection("ParkingDB")
              .document()
              .setData({'Email': un});
          print('User added to the database');
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => bookaslot2(
                      username: un,
                    )));
      } catch (e) {
        switch (e.message) {
          case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
            Flushbar(
              padding: EdgeInsets.all(10),
              borderRadius: 8,
              backgroundColor: Colors.blue,
              boxShadows: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(3, 3),
                  blurRadius: 3,
                ),
              ],
              duration: new Duration(seconds: 4),
              dismissDirection: FlushbarDismissDirection.HORIZONTAL,
              leftBarIndicatorColor: Colors.red,
              forwardAnimationCurve: Curves.easeInOutCubic,
              title: "Oops! Please Check you Internet Connection",
              message: " ",
              flushbarPosition: FlushbarPosition.TOP,
              icon: Icon(
                Icons.network_check,
                color: Colors.red,
              ),
            ).show(context);
            break;
          default:
            Flushbar(
              padding: EdgeInsets.all(10),
              borderRadius: 8,
              backgroundColor: Colors.blue,
              boxShadows: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(3, 3),
                  blurRadius: 3,
                ),
              ],
              duration: new Duration(seconds: 4),
              dismissDirection: FlushbarDismissDirection.HORIZONTAL,
              leftBarIndicatorColor: Colors.red,
              forwardAnimationCurve: Curves.easeInOutCubic,
              title: "Invalid Credentails.! Please try again",
              message: "Please check your Username/Password",
              flushbarPosition: FlushbarPosition.TOP,
              icon: Icon(
                Icons.warning,
                color: Colors.red,
              ),
            ).show(context);
        }
        print(e.message);
      }
    }
  }
}
