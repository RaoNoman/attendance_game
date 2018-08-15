import 'dart:async';
import 'dart:convert';
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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: new MyHomePage(),
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
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
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
  
  ListTile _listcell(DocumentSnapshot dataUser) {
    return  ListTile(
      leading: Icon(
        Icons.ac_unit,
        color: Colors.transparent,
      ),
      title: Text("${dataUser.data}"),
      trailing: Text('1Draw'),
      
    ); 
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
        body: StreamBuilder(
            //stream: Firestore.instance.collection('calender').snapshots(),
            stream: Firestore.instance.collection('date').snapshots(),
            builder: (context, snapshot) {
              print(userId);
              if (!snapshot.hasData) return const Text('Loading...');
                return new ListView.builder(
                  itemCount: snapshot.data.document.length,
                  padding: const EdgeInsets.only(top: 10.0),
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.documents[index];
                     return _listcell(ds);
                  });
            }),
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
   print( Firestore.instance.collection('date').snapshots().length);
    try {
      //if( allowAttedance(time)){
      String barcode = await BarcodeScanner.scan();
      Map<String, dynamic> barcodeData = json.decode(barcode);
      if (barcodeData['id'] == barcodekey) {
       Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
            Firestore.instance.collection("date").document("$date").collection('$userId').document(),{
             // Firestore.instance.collection("$date").document("$userId"),{
                'time' : "true",
            });
        });
       setState(() {
          this.barcode = barcode;
           _showDialog("Attenace submitted succesfully");
        });
      //}
      }
      else{
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

 allowAttedance(DateTime time) async{
  if(time.hour > 9 ){
    print("i retutn flase");
    return true;
  }
  else{
    print("true return ");
    print( Firestore.instance.collection('date').snapshots().length);
    return true;
  }
}

