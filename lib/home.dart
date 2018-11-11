import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shopping_mall/detail.dart';
import 'package:shopping_mall/profile.dart';
import 'package:shopping_mall/add.dart';

class Home extends StatefulWidget {
  final uid;
  Home({Key key, this.uid}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controller = new TextEditingController();
  Firestore fs = Firestore.instance;

  @override
void initState() {
    super.initState();
    print(widget.uid);
}
  String finalSearch = "";
  double price = 150.0;

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.person,
          semanticLabel: 'profile',
        ),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => Profile(uid: widget.uid))),
      ),
      title: Text('SHRINE'),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.add,
            semanticLabel: 'add',
          ),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddItem())),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              children: <Widget>[
                Container(
                  child: Card(
                      elevation: 6.0,
                      margin: const EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          controller: _controller,
                        ),
                      )),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Slider(
                          inactiveColor: Colors.grey[300],
                          activeColor: Colors.grey,
                          value: price,
                          min: 0.0,
                          max: 500.0,
                          onChanged: (value) {
                            setState(() {
                              price = value;
                            });
                          }),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text("\$ ${price.toInt().round().toString()}"),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: Container(
                  child: RaisedButton(
                color: Colors.grey[300],
                child: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    finalSearch = _controller.text.toLowerCase();
                  });
                },
              )))
        ],
      ),
    );
  }

  Widget _buildList(List<DocumentSnapshot> snapshot) {
    return GridView.builder(
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        padding: const EdgeInsets.all(15.0),
        itemCount: snapshot.length,
        itemBuilder: (_, int index) {
          final DocumentSnapshot document = snapshot[index];
          return _buildGridCards(context, document);
        });
  }

  Widget _buildGridCards(BuildContext context, DocumentSnapshot document) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 18 / 11,
            child: Image.network(
              document['imageURL'],
              fit: BoxFit.fitWidth,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(document['name'],
                      softWrap: true,
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("\$${document['price'].toString()}"),
                  Expanded(
                    child: Container(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(pid: document['id'])));
                          },
                          child: Text(
                            "more",
                            style: TextStyle(color: Colors.blue),
                          ),
                        )),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(),
        body: Container(
            child: StreamBuilder(
          stream: Firestore.instance
              .collection('product')
              .where('price', isLessThanOrEqualTo: price)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            else {
              if (snapshot.data.documents != null) {
                if (finalSearch == "") {
                  return Column(
                    children: <Widget>[
                      _buildSearch(),
                      SizedBox(
                        height: 10.0,
                      ),
                      Expanded(child: _buildList(snapshot.data.documents)),
                    ],
                  );
                } else {
                  List<DocumentSnapshot> docSnap = snapshot.data.documents;
                  List<DocumentSnapshot> listSnap = new List<DocumentSnapshot>();

                  docSnap.forEach((d){
                    if(d['name'].toLowerCase()==finalSearch){
                      listSnap.add(d);
                    }
                  });

                  return Column(
                    children: <Widget>[
                      _buildSearch(),
                      SizedBox(
                        height: 10.0,
                      ),
                      Expanded(child: _buildList(listSnap)),
                    ],
                  );

                }
              } else
                return Center(child: CircularProgressIndicator());
            }
          },
        )));
  }
}
