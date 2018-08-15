import 'dart:async';
import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new HomeScreen());

String userId = 'Jhon_420';
String barcodekey = 'John420';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String barcode;

  ListTile _listcell(DocumentSnapshot dataUser) {
    return ListTile(
      leading: Icon(
        Icons.ac_unit,
        color: Colors.transparent,
      ),
      title: Text("${dataUser['userid']}"),
      subtitle: Text("${dataUser['time']}"),
      trailing: RaisedButton(
        child: Icon(
          Icons.person,
        ),
        onPressed: scan,
      ),
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
                  title: Text("Collapsing Toolbar",
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
            stream: Firestore.instance.collection('Attendance').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Loading...');

              return new ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  padding: const EdgeInsets.only(top: 10.0),

                  //itemExtent: 45.0,

                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.documents[index];

                    return _listcell(ds);

                    //return Text(" ${ds['time']} ${ds['votes']}");
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
    try {
      String barcode = await BarcodeScanner.scan();
      Map<String, dynamic> barcodeData = json.decode(barcode);
      if (barcodeData['id'] == barcodekey) {
        var thisInstant = new DateTime.now();
        var time =
            "${thisInstant.hour}:${thisInstant.minute}:${thisInstant.second}";
        print("${barcodeData['id']},${time.toString()}");

        Firestore.instance.runTransaction((transaction) async {
          await transaction
              .set(Firestore.instance.collection("Attendance").document(), {
            'userid': userId,
            'time': time,
          });
        });
        setState(() {
          this.barcode = barcode;
        });
      }
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
