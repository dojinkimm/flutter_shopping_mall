import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:shopping_mall/home.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _userName = "";
  String _imageURL = "";
  String _email = "";

  
  Future _signAnonymously() async {
    final FirebaseUser user = await _auth.signInAnonymously();
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);
    if (Platform.isIOS) {
      assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].uid != null);
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    Firestore.instance.document('users/${user.uid}').get().then((docSnap) {
      if (docSnap.data == null) {
        _newUserSaveDB();
      } else {
        Firestore.instance.document('users/${user.uid}').updateData({
          'lastLoginDate': new DateTime.now(),
        });
        Navigator.pop(context, user.uid); 
      }
    }).catchError((error) {
      print(error);
    });

  }

  Future _signGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    print("signed in " + user.displayName);

    

    Firestore.instance.document('users/${user.uid}').get().then((docSnap) {
      if (docSnap.data == null) {
        _newUserSaveDB();
      } else {
        Firestore.instance.document('users/${user.uid}').updateData({
          'lastLoginDate': new DateTime.now(),
        });
        Navigator.push(context, MaterialPageRoute(builder: (context)=> Home(uid: user.uid,))); 
      }
    }).catchError((error) {
      print(error);
    });
  }

  Future _newUserSaveDB() async {
    FirebaseAuth.instance.currentUser().then((user) {
      if(user.isAnonymous){
        _userName = "Guest";
        _imageURL = "https://firebasestorage.googleapis.com/v0/b/shopping-mall-d0a55.appspot.com/o/default.png?alt=media&token=1da459a0-dfe7-46da-a0ce-727cb63a5a0c";
        _email = "No Email";
      }else{
        _userName = user.displayName;
        _imageURL = user.photoUrl;
        _email = user.email;
      }
      Firestore.instance.collection('users').document(user.uid).setData({
        'displayName': _userName,
        'uid': user.uid,
        'photoURL': _imageURL,
        'email': _email,
        'lastLoginDate': new DateTime.now()
      }).then((d) {
         Navigator.push(context, MaterialPageRoute(builder: (context)=> Home(uid: user.uid,))); 
      }).catchError((e) => print(e));
    });
    //여기에서 저장된 데이터들을 DB로 올림
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Text('Shopping Mall'),
                SizedBox(height: 120.0),
                RaisedButton(
                  onPressed: () => _signGoogle(),
                  child: Text("Google"),
                ),
                SizedBox(height: 10.0),
                RaisedButton(
                  onPressed: ()=>_signAnonymously(),
                  child: Text("Anonymous"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
