import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
class slotshow extends StatefulWidget{
  String slotno;
  String username;
  slotshow({Key key, this.slotno, this.username}) : super (key: key);

  @override
  _slotshow createState() => _slotshow();
}

class _slotshow extends State<slotshow> {

  @override
  void initState() {
    super.initState();
  }


  Future<String> initstate() async {
      QuerySnapshot querySnapshot = await Firestore.instance.collection(
        'ParkingDB')
        .where('Email', isEqualTo: '${widget.username}')
        .getDocuments();
    var doc = querySnapshot.documents;

    if (doc[0]['Slot_no'] != null) {
      await Future.delayed(Duration(seconds: 2));
      String v = "Hello\t" + doc[0]['Email'] + "\t....You have booked the slot\t" + doc[0]['Slot_no'];
      return v;
    }

    else {
      await Future.delayed(Duration(seconds: 2));

      String v = "Hello\t"+ doc[0]['Email'] + '\t....Please book a slot';
      return v;
    }
  }





  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFF9861),

        appBar: AppBar(
          leading:
          IconButton(
            icon: Icon(Icons.arrow_back_ios),

            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => Page2(username: '${widget.username}',)));

            },
          ),

          title: Text('Your Bookings', textAlign: TextAlign.center,),

          backgroundColor: Color(0xFFFF9861),
        ),


        body:
        Container(padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 150.0),
          height: MediaQuery
              .of(context)
              .size
              .height-320.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(80.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black87,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 25.0
                )
              ]

          ),
          child:  FutureBuilder<String>(
              future: initstate(),
              initialData: "Please Wait Loading......",
              builder: (context, snapshot) {

                return new Text(snapshot.data.toString(), style: TextStyle(fontFamily: 'Roboto', fontSize: 25.0, fontWeight: FontWeight.bold),);

             })
              )
      )
    );

  }


}










