import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shopping_mall/edit.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class DetailPage extends StatefulWidget {
  final pid;
  DetailPage({Key key, this.pid}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String creator;
  bool doOrNot;

  @override
  void initState() {
    super.initState();
    doOrNot = false;
    creator = "";
  }

  Future _showDialog(BuildContext context, String editOrDelete) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Really want to do this?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text("YES"),
                onPressed: () {
                  if (editOrDelete == "edit") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditPage(pid: widget.pid)));
                  } else if (editOrDelete == "delete") {
                    print("deleting");
                    Firestore.instance
                        .collection('product')
                        .document(widget.pid)
                        .delete().then((val){
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                  }
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Detail Page"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                final FirebaseUser currentUser = await _auth.currentUser();
                if (currentUser.uid == creator) {
                  _showDialog(context, "edit");
                } else {
                  print("wrong user");
                }
              }),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final FirebaseUser currentUser = await _auth.currentUser();
              if (currentUser.uid == creator) {
                _showDialog(context, "delete");
              } else {
                print("wrong user");
              }
            
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: Firestore.instance
              .collection('product')
              .where('id', isEqualTo: widget.pid)
              .limit(1)
              .getDocuments(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            else {
              final DocumentSnapshot document = snapshot.data.documents[0];

              creator = document['creator'];

              return ListView(children: <Widget>[
                Image.network(
                  document['imageURL'],
                  fit: BoxFit.fitWidth,
                ),
                Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    padding: EdgeInsets.only(top: 50.0, left: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          document['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.blue),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("\$${document['price'].toString()}",
                            style: TextStyle(
                                color: Colors.blue[400], fontSize: 18.0)),
                        Expanded(
                          child: Container(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text("Creator: ${document['creator']}"),
                              Text("Created: ${document['created']}"),
                              Text("Modified: ${document['modified']}"),
                            ],
                          )),
                        )
                      ],
                    )),
              ]);
            }
          }),
    );
  }
}
