import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app4/constants.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _em = new TextEditingController();
  var _un = new TextEditingController();
  String new_user;
  String new_email;

  @override
  void initstate() {
    gmailuserlist();
  }

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
                                  color: Colors.white,
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
                                                color: Colors.blue,
                                                fontFamily: 'Roboto'),
                                          );
                                        } else if(snapshot.data.toString() == 'BOOK NOW'){

                                          return new Text(
                                            snapshot.data.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                                fontFamily: 'Roboto'),
                                          );
                                        }
                                        else{return new Text(
                                          snapshot.data.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                              fontFamily: 'Roboto'),
                                        );}
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
                                subtitle: Text(
                                    snapshot.data[index].data['Email']),
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
            floatingActionButton: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              children: [
                SpeedDialChild(
                    child: Icon(Icons.delete_forever),
                    label: "Delete all the Booked Slots",
                    onTap: () => Alert(
                        context: context,
                        title:
                        "Are you sure you want to cancel all the booked slot",
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
                              deleteAllBookedSlots(); setState(() {
                                gmailuserlist();
                              });
                            },
                            width: 120,
                          ),
                        ]).show()

                ),
                SpeedDialChild(
                    child: Icon(Icons.add),
                    label: "Add new User",
                    onTap: () =>
                        Alert(
                            context: context,
                            title: "ENTER DETAILS",
                            style: AlertStyle(
                              animationType: AnimationType.grow,
                              isCloseButton: false,
                            ),
                            content: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    controller: _un,
                                    validator: (val) =>
                                    val.isEmpty
                                        ? 'Username cannot be empty'
                                        : null,
                                    onSaved: (val) => new_user = val,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.account_circle),
                                      labelText: 'Employee Name',
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _em,
                                    validator: (val) =>
                                    val.isEmpty
                                        ? 'Email cannot be empty'
                                        : null,
                                    onSaved: (val) => new_email = val,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.mail),
                                      labelText: 'Email-Id',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            buttons: [
                              DialogButton(
                                onPressed: () {Navigator.of(context, rootNavigator: true)
                                    .pop(); submitNewData(); setState(() {
                                      gmailuserlist();
                                    });},
                                child: Text(
                                  "SUBMIT",
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                              DialogButton(
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(),
                                child: Text(
                                  "CANCEL",
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              )
                            ]).show()),
              ],
            ),
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

  Future <void> submitNewData() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        final DocumentReference documentReference = Firestore.instance
            .collection("ParkingDB")
            .document(new_user);
        Map<String, String> data = <String, String>{
          "Email": new_email,
        };
        documentReference.setData(data).whenComplete(() {
          print("Document Added");
        }).catchError((e) => print(e));

        final DocumentReference documentReference2 = Firestore.instance
            .collection("Gmailuserlist")
            .document(new_user);
        Map<String, String> data2 = <String, String>{
          "Email": new_email,
        };
        documentReference2.setData(data2).whenComplete(() {
          Fluttertoast.showToast(
              msg: "User Addded",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              fontSize: 20.0);
        }).catchError((e) => print(e));
      } catch (e) {
        print(e);
      }
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
              builder: (context) =>
                  choosealocation2(
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
                  builder: (context) =>
                      gmailuserlist(
                        adminEmail: ademail,
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
                  builder: (context) =>
                      gmailuserlist(
                        adminEmail: ademail,
                      )));
        });
      }
    }
  }


  Future<void> deleteAllBookedSlots() async {

    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('ParkingDB')
        .where('Slot_no', isGreaterThan: ' ')
        .getDocuments();
    var doc = querySnapshot.documents;

    for(var i = 0 ; i < doc.length; i++) {
      if (doc[i]['Slot_no'].toString().substring(0, 2) == 'P1') {
        final DocumentReference documentReference = Firestore.instance
            .collection("Slots")
            .document('Phase-1')
            .collection('totslots')
            .document();
        Map<String, String> data = <String, String>{
          "Slot_no": doc[i]['Slot_no']
        };
        documentReference.setData(data).whenComplete(() {
          print("Document Added");
        }).catchError((e) => print(e));
        Firestore.instance
            .collection('ParkingDB')
            .document(doc[i].documentID)
            .updateData({'Slot_no': FieldValue.delete()}).whenComplete(() {});
      }
      else {
        final DocumentReference documentReference = Firestore.instance
            .collection("Slots")
            .document('Phase-3')
            .collection('totslots')
            .document();
        Map<String, String> data = <String, String>{
          "Slot_no": doc[i]['Slot_no']
        };
        documentReference.setData(data).whenComplete(() {
          print("Document Added");
        }).catchError((e) => print(e));
        Firestore.instance
            .collection('ParkingDB')
            .document(doc[i].documentID)
            .updateData({'Slot_no': FieldValue.delete()}).whenComplete(() {});
      }
    }
    Fluttertoast.showToast(
        msg: "You have deleted all your booked slot",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);

    }
}


