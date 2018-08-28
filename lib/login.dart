import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignIn extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return _GoogelSignIn();
  }
}

class _GoogelSignIn extends State<GoogleSignIn>{
  

  Future<GoogleSignInAccount> _loginWithGoogle() async {
  //GoogleSignInAccount user = ;
 
}
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Center(
          child: RaisedButton(
            child: Text("Google"),
            onPressed: (){

            },
          ),
        )
    );
  }
}