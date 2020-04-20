import 'package:cloud_firestore/cloud_firestore.dart';

const slots = 'Slots';
const p1 = 'Phase-1';
const p3 = 'Phase-3';
const totslots = 'totslots';
const Slot_num = 'Slot_no';
const pdb = 'ParkingDB';
 const name = 'Name';
//const Email = 'Email';
const ascendas_url =
    "https://www.google.com/maps/uv?hl=en&pb=!1s0x3a525d639e47618b%3A0xaa10fd327e29e31c!3m1!7e115!4shttps%3A%2F%2Flh5.googleusercontent.com%2Fp%2FAF1QipO4_ADl2bWjQ6Xaa8un7jOIMAwXbm2HkQCUPjD-%3Dw406-h200-k-no!5sascendas%20it%20park%20chennai%20-%20Google%20Search!15sCAQ&imagekey=!1e10!2sAF1QipNHLg-Eu9OUhgd1uH8T4_OfOHRyMH-BVTr_zeq1&sa=X&ved=2ahUKEwidp-vWpefmAhUnzjgGHce7CCoQoiowFHoECB0QBg";
const tidel_url =
    "https://content3.jdmagicbox.com/comp/chennai/95/044p7003295/catalogue/tidel-park-ltd-tharamani-chennai-business-centres-8zavy.jpg?clr=264040";

// Get Slots for Phase - 1
getslotP1() async {
  QuerySnapshot q2 = await Firestore.instance
      .collection(slots)
      .document(p1)
      .collection(totslots)
      .where(Slot_num, isGreaterThan: '')
      .getDocuments();
  int slotsP1 = 16;
  int t = q2.documents.length;
  String v = t.toString() + '/' + slotsP1.toString();
  return v;
}

//Get Slots for Phase - 2
getslotP2() async {
  QuerySnapshot q2 = await Firestore.instance
      .collection(slots)
      .document(p3)
      .collection(totslots)
      .where(Slot_num, isGreaterThan: '')
      .getDocuments();
  int slotsP2 = 9;
  int t = q2.documents.length;
  String v = t.toString() + '/' + slotsP2.toString();
  return v;
}

//Get total slots
Future<String> getslot() async {
  QuerySnapshot q = await Firestore.instance
      .collection(pdb)
      .where(Slot_num, isGreaterThan: '')
      .getDocuments();
  int t = 25; // Total number of slots available
  int s = 25 - q.documents.length;
  String v = s.toString() + '/' + t.toString();
  return v;
}

//Minimum distance for the user(with vehicle) to be present to book a slot

double getdist() {
  return 1000; // The value 1000 is in meters i.e. 1 KM
}

Future getdataP1() async {
  QuerySnapshot q1 = await Firestore.instance
      .collection(slots)
      .document(p1)
      .collection(totslots)
      .orderBy(Slot_num)
      .getDocuments();
  return q1.documents;
}

Future getdataP2() async {
  QuerySnapshot q1 = await Firestore.instance
      .collection(slots)
      .document(p3)
      .collection(totslots)
      .orderBy(Slot_num)
      .getDocuments();
  return q1.documents;
}

Future getdataE1() async {
  QuerySnapshot q1 =
      await Firestore.instance.collection("Gmailuserlist").getDocuments();
  return q1.documents;
}
