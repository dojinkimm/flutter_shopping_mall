import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

final auth = FirebaseAuth.instance;
final googleSignIn = new GoogleSignIn();

class AddItem extends StatefulWidget {
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();

  String _name = "";
  String _price = "";
  String _imageURL;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _imageURL =
        "https://firebasestorage.googleapis.com/v0/b/shopping-mall-d0a55.appspot.com/o/default.png?alt=media&token=1da459a0-dfe7-46da-a0ce-727cb63a5a0c";
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
          automaticallyImplyLeading: false,
          leading: Container(
            padding: EdgeInsets.only(left: 10.0),
            alignment: Alignment.center,
            child: InkWell(
            child: Text("Cancel"),
            onTap: () => Navigator.pop(context),
          ),
          ),
          title: Text("Add"),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              child: Text("Save"),
              onPressed: _submit,
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
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
                        validator: (val) =>
                            val.isEmpty ? 'Please write product name' : null,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                        ),
                        onSaved: (val) => _name = val,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    ListTile(
                      title: TextFormField(
                        validator: (val) =>
                            val.isEmpty ? 'Please write price' : null,
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                        onSaved: (val) => _price = val,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Future uploadImage() async {
    String uuid = Uuid().v1();
    final File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 300.0, maxWidth: 300.0);
    StorageReference storageRef = FirebaseStorage.instance
        .ref()
        .child("img_$uuid.jpg");
    StorageUploadTask uploadTask = storageRef.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    setState(() {
      _imageURL = downloadUrl;
    });
  }

  void _submit() {
    final form = formKey.currentState;

    if (form.validate() && _name != null && _price != null) {
      form.save();
      _completeForm();
    }
  }

  Future _completeForm() async {
    String uuid = Uuid().v1();
    FirebaseAuth.instance.currentUser().then((user) async {
      Firestore.instance.collection('product').document(uuid).setData({
        'id': uuid,
        'imageURL': _imageURL,
        'name': _name,
        'price': int.parse(_price),
        'creator': user.uid,
        'created': new DateTime.now(),
        'modified': new DateTime.now()
      }).whenComplete(() {
        print("DB에 저장 완료");
        Navigator.pop(context);
      }).catchError((e) => print(e));
    });
    //여기에서 저장된 데이터들을 DB로 올림
  }
}
