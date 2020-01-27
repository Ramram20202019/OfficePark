import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'choosealocation2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:great_circle_distance2/great_circle_distance2.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';



// ignore: must_be_immutable, camel_case_types
class bookaslot extends StatefulWidget{
  String username;
  String park;
  bookaslot({Key key, this.username}) : super (key: key);

  @override
  _bookaslot createState() => _bookaslot();
}


// ignore: camel_case_types
class _bookaslot extends State<bookaslot> with WidgetsBindingObserver {

  Location location = new Location();

  @override
  void initState() {
    super.initState();
    _animateToUser();
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

    if(state == AppLifecycleState.resumed){

    }else if(state == AppLifecycleState.inactive){
      // app is inactive
    }else if(state == AppLifecycleState.paused){
      // user quit our app temporally
    }
  }
  Completer<GoogleMapController> _controller = Completer();



  @override
  Widget build(BuildContext context) {
    return MaterialApp(


      home: Scaffold(
        appBar: AppBar(leading:
        IconButton(
          icon: Icon(Icons.arrow_back_ios),

          onPressed: () { Navigator.pop(context);

          },
        ),

          title: Text('Choose a Location', textAlign: TextAlign.center,),
          actions: <Widget>[
            new IconButton(icon: Icon(MdiIcons.logout, color: Color(0xFFFFFFFF), size: 35.0,), onPressed: (){_signout(context);})],
          backgroundColor: Color(0xFFFF9861),
        ),
        body: Stack(
          children: <Widget>[
            _buildGoogleMap(context),
            _buildContainer(),

          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {

    return Container(

        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
              target: LatLng(12.9864, 80.2425), zoom: 14),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);



          },

          myLocationEnabled: true,
          myLocationButtonEnabled: true,

          markers: {
            ascendasmarker, tidelmarker,
          },
        )
    );
  }



  Marker ascendasmarker = Marker(
    markerId: MarkerId('Ascendas IT Park'),
    position: LatLng(12.9858, 80.2459),

    infoWindow: InfoWindow(title: 'Ascendas IT Park, Taramani', ),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    ),
  );

  Marker tidelmarker = Marker(
    markerId: MarkerId('Tidel Park'),
    position: LatLng(12.9896, 80.2486),
    infoWindow: InfoWindow(title: 'Tidel Park'),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    ),
  );


  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://www.google.com/maps/uv?hl=en&pb=!1s0x3a525d639e47618b%3A0xaa10fd327e29e31c!3m1!7e115!4shttps%3A%2F%2Flh5.googleusercontent.com%2Fp%2FAF1QipO4_ADl2bWjQ6Xaa8un7jOIMAwXbm2HkQCUPjD-%3Dw406-h200-k-no!5sascendas%20it%20park%20chennai%20-%20Google%20Search!15sCAQ&imagekey=!1e10!2sAF1QipNHLg-Eu9OUhgd1uH8T4_OfOHRyMH-BVTr_zeq1&sa=X&ved=2ahUKEwidp-vWpefmAhUnzjgGHce7CCoQoiowFHoECB0QBg",
                  12.9858, 80.2459, "Ascendas IT Park, Taramani"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://content3.jdmagicbox.com/comp/chennai/95/044p7003295/catalogue/tidel-park-ltd-tharamani-chennai-business-centres-8zavy.jpg?clr=264040",
                  12.9896, 80.2486, "Tidel Park, Chennai"),
            ),

          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _boxes(String _image, double lat, double long, String ParkName) {
    return GestureDetector(
      onTap: () async {
        switch(ParkName) {
          case 'Ascendas IT Park, Taramani':
            var pos = await location.getLocation();
           var gcd = GreatCircleDistance.fromDegrees(latitude1: pos.latitude, longitude1: pos.longitude, latitude2: lat, longitude2: long);
            if(gcd.sphericalLawOfCosinesDistance() <= 1000){
            Navigator.push(
                context, MaterialPageRoute(builder: (context) =>
                choosealocation2(username: '${widget.username}',)));}
            else{ Fluttertoast.showToast(
                msg: "Cannot book a slot, if you are more than 1Km from the parking location",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);}

        }

      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(ParkName),
                    ),
                  ),

                ],)
          ),
        ),
      ),
    );
  }

  /*Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, long), zoom: 15, tilt: 50.0,
          bearing: 45.0,)));
  }*/


_animateToUser() async {
  var pos = await location.getLocation();

  final GoogleMapController controller = await _controller.future;
  controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 15, tilt: 50.0,
        bearing: 45.0,)));


}



  Future<String> getslot() async {
    QuerySnapshot q = await Firestore.instance.collection('ParkingDB').where('Slot_no', isGreaterThan: '').getDocuments();
    int t = 10;
    int s = 10 - q.documents.length;
    String v = s.toString() + '/' + t.toString();
    return v;

  }



  // ignore: missing_return
  Widget myDetailsContainer1(String ParkName) {
    switch(ParkName) {
      case 'Ascendas IT Park, Taramani':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                  child: Text(ParkName,
                    style: TextStyle(
                        color: Color(0xff6200ee),
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold),
                  )),
            ),
            SizedBox(height: 5.0),
            Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        child: Text(
                          "Slots Available",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto'
                          ),
                        )),
                    Container(
                      child: FutureBuilder<String>(
                          future: getslot(),
                          initialData: "Please Wait Loading......",
                          builder: (context, snapshot) {
                            return new Text(
                              snapshot.data.toString(), style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold),);
                          }
                      ),
                    ),

                  ],
                )),

          ],
        ); break;
      case 'Tidel Park, Chennai':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                  child: Text(ParkName,
                    style: TextStyle(
                        color: Color(0xff6200ee),
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold),
                  )),
            ),
            SizedBox(height: 5.0),

                    Container(
                        child: Text(
                          "Coming Soon",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto'
                          ),
                        )),
          ]
        );

    }
  }
  _signout(context) async {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure you want to Logout? ",
      buttons: [
        DialogButton(
          child: Text(
            "NO",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        ),
        DialogButton(
          child: Text(
            "YES",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async{
            try {
              await FirebaseAuth.instance.signOut();

              Fluttertoast.showToast(
                  msg: "Loggedout Succesfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIos: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(
                  builder: (context) => MyHomePage()));
            }
            catch (e) {
              print(e.message);
            }

          },
          width: 120,
        ),
      ],
    ).show();


  }


}




