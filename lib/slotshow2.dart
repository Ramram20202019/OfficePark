import 'package:flutter_app4/bookaslot2.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable, camel_case_types
class slotshow2 extends StatefulWidget {
  String slotno;
  String username;

  slotshow2({Key key, this.slotno, this.username}) : super(key: key);

  @override
  _slotshow2 createState() => _slotshow2();
}

// ignore: camel_case_types
class _slotshow2 extends State<slotshow2> with WidgetsBindingObserver {
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

  Future<String> initstate() async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('ParkingDB')
        .where('Email', isEqualTo: '${widget.username}')
        .getDocuments();
    var doc = querySnapshot.documents;

    if (doc[0]['Slot_no'] != null) {
      await Future.delayed(Duration(seconds: 2));
      String v = "You have booked the slot\t" + doc[0]['Slot_no'];
      return v;
    } else {
      await Future.delayed(Duration(seconds: 2));

      String v = "No Bookings Yet";
      return v;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
          child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => bookaslot2(
                                  username: '${widget.username}',
                                )));
                  },
                ),
                title: Text(
                  'Your Bookings',
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
                          }))
                ],
                backgroundColor: Colors.blue,
              ),
              body: Center(
                  child: Center(
                child: Scaffold(
                  body: Container(
                      child: FutureBuilder<String>(
                          future: initstate(),
                          initialData: "Loading",
                          builder: (context, snapshot) {
                            return Container(
                              height: 100.0,
                              child: Card(
                                margin:
                                    EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        snapshot.data.toString(),
                                        style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 15.0),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(Icons.cancel),
                                          color: Colors.red,
                                          onPressed: () async {
                                            bool _isbe;
                                            QuerySnapshot querySnapshot =
                                                await Firestore.instance
                                                    .collection('ParkingDB')
                                                    .where('Email',
                                                        isEqualTo:
                                                            '${widget.username}')
                                                    .getDocuments();
                                            var doc = querySnapshot.documents;
                                            if (doc[0]['Slot_no'] != null) {
                                              _isbe = true;
                                            } else {
                                              _isbe = false;
                                            }

                                            // ignore: unnecessary_statements
                                            _isbe
                                                ? Alert(
                                                    context: context,
                                                    title:
                                                        "Are you sure you want to Cancel your booked slot",
                                                    type: AlertType.warning,
                                                    style: AlertStyle(
                                                      animationType:
                                                          AnimationType.grow,
                                                      isCloseButton: false,
                                                    ),
                                                    buttons: [
                                                        DialogButton(
                                                          child: Text(
                                                            "NO",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20),
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true)
                                                                  .pop(),
                                                          width: 120,
                                                        ),
                                                        DialogButton(
                                                          child: Text(
                                                            "YES",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                            checkdata();
                                                          },
                                                          width: 120,
                                                        ),
                                                      ]).show()
                                                : null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })),
                ),
              )))),
    );
  }

  Future<void> checkdata() async {
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
        .where('Email', isEqualTo: '${widget.username}')
        .getDocuments();
    var doc = querySnapshot.documents;

    if (doc[0]['Slot_no'] != null) {
      if (doc[0]['Slot_no'].toString().substring(0, 2) == 'P1') {
        final DocumentReference documentReference = Firestore.instance
            .collection("Slots")
            .document('Phase-1')
            .collection('totslots')
            .document();
        Map<String, String> data = <String, String>{
          "Slot_no": doc[0]['Slot_no']
        };
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
                  builder: (context) => bookaslot2(
                        username: '${widget.username}',
                      )));
        });
      } else {
        final DocumentReference documentReference = Firestore.instance
            .collection("Slots")
            .document('Phase-3')
            .collection('totslots')
            .document();
        Map<String, String> data = <String, String>{
          "Slot_no": doc[0]['Slot_no']
        };
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
                  builder: (context) => bookaslot2(
                        username: '${widget.username}',
                      )));
        });
      }
    }
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
