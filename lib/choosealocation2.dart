import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app4/constants.dart';
import 'package:flutter_app4/gmailuserlist.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'slotshow2.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// ignore: must_be_immutable, camel_case_types
class choosealocation2 extends StatefulWidget {
  String username;
  String getemail;
  Function(Future<String>) callback;

  choosealocation2({Key key, this.username, this.getemail}) : super(key: key);

  @override
  _choosealocation2state createState() => _choosealocation2state();
}

// ignore: camel_case_types
class _choosealocation2state extends State<choosealocation2>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var refreshKey2 = GlobalKey<RefreshIndicatorState>();

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

  bool showFab = true;

  @override
  Widget build(BuildContext context) {
    void _add(i) async {
      /*showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text("Booking the Slot. Please Wait", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              children: <Widget>[SpinKitPulse(color: Colors.blue,),],
            );
          });*/
      Fluttertoast.showToast(
          msg: "Booking the Slot.. Please Wait",
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

      Future ret() async {
        QuerySnapshot q = await Firestore.instance
            .collection('ParkingDB')
            .where('Slot_no', isGreaterThan: '')
            .getDocuments();
        bool i1 = false;
        var d = q.documents;
        for (int j = 0; j < q.documents.length; j++) {
          if (i.toString() == d[j]['Slot_no'].toString()) {
            i1 = true;
          }
        }
        return i1;
      }

      bool j = await ret();
      if (j) {
        Fluttertoast.showToast(
            msg:
                "This Slot has already been booked. Please choose another slot",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        final DocumentReference documentReference = Firestore.instance
            .collection("ParkingDB")
            .document(doc[0].documentID);
        Map<String, String> data = <String, String>{
          "Email": "${widget.username}",
          "Slot_no": i,
        };
        documentReference.updateData(data).whenComplete(() {
          print("Document Added");
        }).catchError((e) => print(e));

        if (i.toString().substring(0, 2) == 'P1') {
          QuerySnapshot q2 = await Firestore.instance
              .collection('Slots')
              .document('Phase-1')
              .collection('totslots')
              .where('Slot_no', isEqualTo: i)
              .getDocuments();
          var doc1 = q2.documents;

          Firestore.instance
              .collection("Slots")
              .document('Phase-1')
              .collection('totslots')
              .document(doc1[0].documentID)
              .delete();

          Fluttertoast.cancel();
          if ('${widget.getemail}' == 'chnsag4app@gmail.com') {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => gmailuserlist(
                          adminEmail: "${widget.getemail}",
                        )));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => slotshow2(
                          slotno: i,
                          username: "${widget.username}",
                        )));
          }
        } else {
          QuerySnapshot q2 = await Firestore.instance
              .collection('Slots')
              .document('Phase-3')
              .collection('totslots')
              .where('Slot_no', isEqualTo: i)
              .getDocuments();
          var doc1 = q2.documents;

          Firestore.instance
              .collection("Slots")
              .document('Phase-3')
              .collection('totslots')
              .document(doc1[0].documentID)
              .delete();

          Fluttertoast.cancel();
          if ('${widget.getemail}' == 'chnsag4app@gmail.com') {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => gmailuserlist(
                          adminEmail: "${widget.getemail}",
                        )));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => slotshow2(
                          slotno: i,
                          username: "${widget.username}",
                        )));
          }
        }
      }
    }

    List<Widget> containers = [
      SafeArea(
          child: Container(
              child: Scaffold(
        body: new RefreshIndicator(
            key: refreshKey,
            child: FutureBuilder(
              future: getdataP1(),
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
                  if (snapshot.data.length == 0) {
                    return Container(
                      child: Center(
                        child: Text("Sorry. All the slots has been booked",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            )),
                      ),
                    );
                  } else {
                    return ListView.separated(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            trailing: new RaisedButton(
                              color: Colors.green,
                              onPressed: () {
                                _add(snapshot.data[index].data['Slot_no']);
                              },
                              //
                              child: Text(
                                'BOOK NOW',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Roboto'),
                              ),
                              splashColor: Colors.grey,
                            ),
                            leading: new RawMaterialButton(
                              onPressed: () {},
                              child: new Icon(
                                MdiIcons.car,
                                color: Colors.blue,
                                size: 45.0,
                              ),
                              shape: new CircleBorder(),
                              elevation: 2.0,
                              fillColor: Colors.white,
                              padding: const EdgeInsets.all(5.0),
                            ),
                            title: Text(snapshot.data[index].data['Slot_no']),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        });
                  }
                }
              },
            ),
            onRefresh: () async {
              refreshKey.currentState?.show(atTop: false);
              await new Future.delayed(new Duration(seconds: 3));
              setState(() {
                getdataP1();
                getdataP2();
              });
              return null;
            }),
      ))),
      SafeArea(
          child: Container(
              child: Scaffold(
        body: new RefreshIndicator(
          key: refreshKey2,
          child: FutureBuilder(
            future: getdataP2(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasData == null) {
                return Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Loading...',
                          style:
                              TextStyle(fontSize: 20.0, fontFamily: 'Roboto'),
                        ),
                        CircularProgressIndicator(
                          strokeWidth: 2.0,
                        )
                      ]),
                );
              } else {
                if (snapshot.data.length == 0) {
                  return Container(
                    child: Center(
                      child: Text("Sorry. All the slots has been booked",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          )),
                    ),
                  );
                } else {
                  return ListView.separated(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          trailing: new RaisedButton(
                            color: Colors.green,
                            onPressed: () {
                              _add(snapshot.data[index].data['Slot_no']);
                            },
                            //
                            child: Text(
                              'BOOK NOW',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Roboto'),
                            ),
                            splashColor: Colors.grey,
                          ),
                          leading: new RawMaterialButton(
                            onPressed: () {},
                            child: new Icon(
                              MdiIcons.car,
                              color: Colors.blue,
                              size: 45.0,
                            ),
                            shape: new CircleBorder(),
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(5.0),
                          ),
                          title: Text(snapshot.data[index].data['Slot_no']),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      });
                }
              }
            },
          ),
          onRefresh: () async {
            refreshKey2.currentState?.show(atTop: false);
            await Future.delayed(Duration(seconds: 3));
            setState(() {
              getdataP1();
              getdataP2();
            });
            return null;
          },
        ),
      ))),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Choose a Slot',
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
          elevation: 0.7,
          backgroundColor: Colors.blue,
          bottom: TabBar(tabs: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Tab(
                  text: 'PHASE-1\t\t',
                ),
                FutureBuilder(
                    future: getslotP1(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.hasData == null) {
                        return CircularProgressIndicator();
                      } else {
                        return Text(
                          '(' + snapshot.data.toString() + ')',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        );
                      }
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Tab(
                  text: 'PHASE-3\t\t',
                ),
                FutureBuilder(
                    future: getslotP2(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.hasData == null) {
                        return CircularProgressIndicator();
                      } else {
                        return Text(
                          '(' + snapshot.data.toString() + ')',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        );
                      }
                    })
              ],
            )
          ]),
        ),
        body: TabBarView(
          children: containers,
        ),
      ),
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
