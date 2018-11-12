import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPage extends StatefulWidget {
  final pid;
  EditPage({Key key, this.pid}) : super(key: key);
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();

  String _name;
  String _price;
  String _imageURL;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _name = "";
    _price = "";
    _imageURL = "";
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _priceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Edit"),
        leading: Container(
            padding: EdgeInsets.only(left: 10.0),
            alignment: Alignment.center,
            child: InkWell(
            child: Text("Cancel"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          ),
        actions: <Widget>[
          FlatButton(
            child: Text("Save"),
            onPressed: _submit,
          )
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

              _name = document['name'];
              _price = document['price'].toString();
              _imageURL = document['imageURL'];

              return ListView(children: <Widget>[
                Image.network(
                  _imageURL,
                  fit: BoxFit.fitWidth,
                ),
                Container(
                    padding: EdgeInsets.all(15.0),
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () => uploadImage(),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: TextFormField(
                              validator: (val) => val.isEmpty
                                  ? 'Please write product name'
                                  : null,
                              decoration: InputDecoration(
                                hintText: _name,
                              ),
                              onSaved: (val) {
                                setState(() {
                                  _name = val;
                                });
                              }),
                        ),
                        SizedBox(height: 12.0),
                        ListTile(
                          title: TextFormField(
                              validator: (val) =>
                                  val.isEmpty ? 'Please write price' : null,
                              decoration: InputDecoration(
                                hintText: _price,
                              ),
                              onSaved: (val) {
                                setState(() {
                                  _price = val;
                                });
                              }),
                        ),
                      ],
                    ),
                  ),
                )
              ]);
            }
          }),
    );
  }

  Future uploadImage() async {
    final File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 300.0, maxWidth: 300.0);
    int timestamp = new DateTime.now().millisecondsSinceEpoch;
    StorageReference storageRef = FirebaseStorage.instance
        .ref()
        .child("img_" + timestamp.toString() + ".jpg");
    StorageUploadTask uploadTask = storageRef.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    setState(() {
      _imageURL = downloadUrl;
    });
  }

  void _submit() {
    final form = formKey.currentState;

    if (form.validate() && _name != null) {
      form.save();
      _completeForm();
    }
  }

  Future _completeForm() async {
    FirebaseAuth.instance.currentUser().then((user) async {
      Firestore.instance.collection('product').document(widget.pid).updateData({
        'imageURL': _imageURL,
        'name': _name,
        'price': int.parse(_price),
        'modified': new DateTime.now()
      }).whenComplete(() {
        print("DB에 저장 완료");
        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((e) => print(e));
    });
    //여기에서 저장된 데이터들을 DB로 올림
  }
}
