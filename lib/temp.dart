

import 'package:danim/src/app.dart';
import 'package:danim/src/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Temp extends StatefulWidget {
  const Temp({Key? key}) : super(key: key);

  @override
  _TempState createState() => _TempState();
}

class _TempState extends State<Temp> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            print(snapshot.data);
            token=FirebaseAuth.instance.currentUser?.uid;
            userName=FirebaseAuth.instance.currentUser?.displayName;
            userEmail=FirebaseAuth.instance.currentUser?.email;
            print('$token $userName $userEmail');
            if (snapshot.hasData) {
              return App();
            }
            else {
              return Login();
            }
          }
        });
  }
}