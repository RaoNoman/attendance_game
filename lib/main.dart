import 'dart:async';
import 'dart:convert';
import 'package:attendance_game/login.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

void main() => runApp(new HomeScreen());
var time = new DateTime.now();
var date = "${time.month}-${time.day}-${time.year}";
var obj = Random();
var counter = obj.nextInt(10);
String userId = 'Jhon_1111$counter';
String barcodekey = 'John420';
List<MyData> items = List<MyData>();
bool loading = true;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
     // home: new MyHomePage(),
       home: GoogleSignIn(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  
  String barcode;
  void _showDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Alert Dialog title"),
          content: new Text("$text"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    print('asdasdasd i satrt');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text("Attendances",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Image.network(
                    "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
        body: BookList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: scan,
        label: Text('Check in'),
        icon: Icon(Icons.center_focus_weak),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future scan() async {
    print(userId);
    print(Firestore.instance.collection('date').snapshots().length);
    try {
      //if( allowAttedance(time)){
      String barcode = await BarcodeScanner.scan();
      Map<String, dynamic> barcodeData = json.decode(barcode);
      if (barcodeData['id'] == barcodekey) {
        Firestore.instance.runTransaction((transaction) async {
          await transaction
              .set(Firestore.instance.collection("date").document("$date"), {
            // Firestore.instance.collection("$date").document("$userId"),{
            'time': "true",
          });
        });
        setState(() {
          this.barcode = barcode;
          _showDialog("Attenace submitted succesfully");
        });
        //}
      } else {
        print("Not allowed to attendace");
        setState(() {
          print("set sattae alert");
          _showDialog("Soryy you are late");
        });
      }
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}

allowAttedance(DateTime time) async {
  if (time.hour > 9) {
    print("i retutn flase");
    return true;
  } else {
    print("true return ");
    print(Firestore.instance.collection('date').snapshots().length);
    return true;
  }
}
class BookList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _BookList();
  }

}

class _BookList extends State<BookList> {
  Future getdata(String documentid) async {
  //'2018-07-20 20:18:04am'
   QuerySnapshot userdata = await Firestore.instance.collection('date').document('$documentid').collection('data').getDocuments();
   items = userdata.documents.map((i)=>MyData.fromJson(i)).toList();
   if(!items.isEmpty) { 
     setState(() {
          loading=false;
          }); }
    print(items[0].name);
}
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('date').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Text('Loading...');
        return ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            getdata(document.documentID);
            return loading ? CircularProgressIndicator() : Padding(
                padding: const EdgeInsets.all(8.0),
                          child: ExpansionTile(
                  title: Text("${document.documentID}"),
                   children: items.map((c) {
                     return ListTile(
                       title: Text(c.name),
                       trailing: Text(c.time),
                       );
                  }).toList(),
                  ),
            );
          }).toList(),
        );
      },
    );
  }
}

class MyData{
  final String time;
  final String name;

  MyData({this.time, this.name});

  MyData.fromJson(DocumentSnapshot json)
  : this.time = json['time'],
    this.name = json['name'];
}
