import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

import 'package:shopping_mall/login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class Profile extends StatefulWidget {
  final uid;
  Profile({Key key, this.uid}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
    void initState() {
      super.initState();
      print(widget.uid);
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: FutureBuilder(
            future: Firestore.instance
                .collection('users')
                .where('uid', isEqualTo: widget.uid)
                .getDocuments(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              else {
                
                final DocumentSnapshot document = snapshot.data.documents[0];
                print(widget.uid);
                if(document['displayName']!=null){
                
                return ListView(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 80.0),
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Image.network(
                        document['photoURL'],
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          SizedBox(height: 60.0),
                          Container(
                            child: Text(
                              "Name: ${document['displayName']}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            child: Text(
                              "UID: ${document['uid']}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            child: Text(
                              "Email: ${document['email']}",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
                }else{
                    return Center(child: CircularProgressIndicator());
                }
                
              }
            }));
  }

  Future<Login> _logout() async {
    print("logout");
    await _auth.signOut();
    await _googleSignIn.signOut();
    // return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Login()),  ModalRoute.withName('/login'));
    return Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
  }
}
