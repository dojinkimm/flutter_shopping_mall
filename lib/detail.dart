import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shopping_mall/edit.dart';

class DetailPage extends StatefulWidget {
  final pid;
  DetailPage({Key key, this.pid}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Detail Page"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>EditPage())),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle),
            onPressed: () {},
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
              return ListView(children: <Widget>[
                Image.network(
                  document['imageURL'],
                  fit: BoxFit.fitWidth,
                ),
                Container(
                  height: MediaQuery.of(context).size.height*0.4,
                  padding: EdgeInsets.only(top: 50.0, left: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(document['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.blue),),
                      SizedBox(height: 10.0,),
                      Text("\$${document['price'].toString()}", style: TextStyle(color: Colors.blue[400], fontSize: 18.0)),
                      Expanded(child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text("creator: ${widget.pid}"),
                            Text("Created"),
                            Text("Modified"),
                          ],
                        )
                      ),)
                    ],
                  )
                ),

              ]);
            }
          }),
    );
  }
}
