import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app4/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'choosealocation2.dart';
import 'main.dart';

class gmailuserlist extends StatefulWidget {
  String adminEmail;

  gmailuserlist({Key key, this.adminEmail}) : super(key: key);

  @override
  _gmailuserliststate createState() => _gmailuserliststate();
}

class _gmailuserliststate extends State<gmailuserlist> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Choose Your Name',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Transform.scale(
                scale: 0.7,
                child: new IconButton(
                    icon: Icon(
                      MdiIcons.logout,
                      color: Color(0xFFFFFFFF),
                      size: 35.0,
                    ),
                    onPressed: () {
                      _signout(context);
                    })),
          ],
        ),
        body: RefreshIndicator(
            key: refreshKey,
            child: FutureBuilder(
                future: getdataE1(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.hasData == null) {
                    return Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SpinKitFadingCircle(
                              color: Colors.blue,
                              size: 50.0,
                            )
                          ]),
                    );
                  } else {
                    return ListView.separated(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            trailing: new RaisedButton(
                              color: Colors.green,
                              onPressed: () {
                                checkgmailuser(
                                    snapshot.data[index].data['Email'],
                                    context,
                                    '${widget.adminEmail}');
                              },
                              //
                              child: FutureBuilder(
                                  future: checkUserSlot(
                                      snapshot.data[index].data['Email']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.hasData == null) {
                                      return new Text(
                                        "Loading..",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Roboto'),
                                      );
                                    } else {
                                      return new Text(
                                        snapshot.data.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Roboto'),
                                      );
                                    }
                                  }),
                              splashColor: Colors.grey,
                            ),
                            leading: new RawMaterialButton(
                              onPressed: () {},
                              child: new Icon(
                                Icons.account_circle,
                                color: Colors.blue,
                                size: 45.0,
                              ),
                              shape: new CircleBorder(),
                              elevation: 2.0,
                              fillColor: Colors.white,
                              padding: const EdgeInsets.all(5.0),
                            ),
                            subtitle: Text(snapshot.data[index].data['Email']),
                            title: Text(snapshot.data[index].documentID),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        });
                  }
                }),
            onRefresh: () async {
              refreshKey.currentState?.show(atTop: false);
              await new Future.delayed(new Duration(seconds: 3));
              setState(() {
                gmailuserlist();
              });
              return null;
            }),
      )),
    );
  }

  _signout(context) async {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure you want to Logout? ",
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "NO",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          width: 120,
        ),
        DialogButton(
          child: Text(
            "YES",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
            try {
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('email');
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()));
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
                forwardAnimationCurve: Curves.easeInOutCubic,
                title: "Logged Out Successfully",
                message: " ",
                flushbarPosition: FlushbarPosition.TOP,
                icon: Icon(
                  Icons.thumb_up,
                  color: Colors.white,
                ),
              ).show(context);
            } catch (e) {
              print(e.message);
            }
          },
          width: 120,
        ),
      ],
    ).show();
  }
}

checkUserSlot(email) async {
  QuerySnapshot querySnapshot = await Firestore.instance
      .collection('ParkingDB')
      .where('Email', isEqualTo: email)
      .getDocuments();
  var doc = querySnapshot.documents;

  if (doc[0]['Slot_no'] != null) {
    return doc[0]['Slot_no'].toString();
  } else {
    return 'BOOK NOW';
  }
}

Future<void> checkgmailuser(email1, context, adminemail) async {
  Fluttertoast.showToast(
      msg: "Loading.. Please Wait",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 20.0);

  QuerySnapshot querySnapshot = await Firestore.instance
      .collection('ParkingDB')
      .where('Email', isEqualTo: email1)
      .getDocuments();
  var doc = querySnapshot.documents;

  if (doc[0]['Slot_no'] != null) {
    Fluttertoast.cancel();
    Alert(
        context: context,
        title: "Are you sure you want to cancel your booked slot\t" +
            doc[0]['Slot_no'],
        type: AlertType.error,
        style: AlertStyle(
          animationType: AnimationType.grow,
          isCloseButton: false,
        ),
        buttons: [
          DialogButton(
            child: Text(
              "NO",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            width: 120,
          ),
          DialogButton(
            child: Text(
              "YES",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              checkdata(email1, context, adminemail);
            },
            width: 120,
          )
        ]).show();
  } else {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => choosealocation2(
                  username: email1,
                  getemail: adminemail,
                )));
  }
}

Future<void> checkdata(mail, context, ademail) async {
  /*showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Cancelling. Please Wait", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            children: <Widget>[SpinKitThreeBounce(color: Colors.blue,),],
          );
        });*/
  Fluttertoast.showToast(
      msg: "Cancelling.. Please Wait",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 20.0);

  QuerySnapshot querySnapshot = await Firestore.instance
      .collection('ParkingDB')
      .where('Email', isEqualTo: mail)
      .getDocuments();
  var doc = querySnapshot.documents;

  if (doc[0]['Slot_no'] != null) {
    if (doc[0]['Slot_no'].toString().substring(0, 2) == 'P1') {
      final DocumentReference documentReference = Firestore.instance
          .collection("Slots")
          .document('Phase-1')
          .collection('totslots')
          .document();
      Map<String, String> data = <String, String>{"Slot_no": doc[0]['Slot_no']};
      documentReference.setData(data).whenComplete(() {
        print("Document Added");
      }).catchError((e) => print(e));
      Firestore.instance
          .collection('ParkingDB')
          .document(doc[0].documentID)
          .updateData({'Slot_no': FieldValue.delete()}).whenComplete(() {
        Fluttertoast.showToast(
            msg: "You have cancelled your slot",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => gmailuserlist(
                      adminEmail: ademail,
                    )));
      });
    } else {
      final DocumentReference documentReference = Firestore.instance
          .collection("Slots")
          .document('Phase-3')
          .collection('totslots')
          .document();
      Map<String, String> data = <String, String>{"Slot_no": doc[0]['Slot_no']};
      documentReference.setData(data).whenComplete(() {
        print("Document Added");
      }).catchError((e) => print(e));
      Firestore.instance
          .collection('ParkingDB')
          .document(doc[0].documentID)
          .updateData({'Slot_no': FieldValue.delete()}).whenComplete(() {
        Fluttertoast.showToast(
            msg: "You have cancelled your slot",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => gmailuserlist(
                      adminEmail: ademail,
                    )));
      });
    }
  }
}
