import 'package:flutter/material.dart';

class AddItem extends StatefulWidget {
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();

  String _name = "";
  String _price = "";

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: FlatButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
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
            Image.asset(
              "images/default.png",
              fit: BoxFit.fitWidth,
            ),
            Container(
                padding: EdgeInsets.all(15.0),
                alignment: Alignment.centerRight,
                child: Icon(Icons.camera_alt)),
//////////////////////////////////
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

  void _submit() {
    final form = formKey.currentState;

    if (form.validate() && _name != null && _price != null) {
      form.save();
      // _completeForm();
    }
  }

  // Future _completeForm() async {
  //   FirebaseAuth.instance.currentUser().then((user){
  //     Firestore.instance.collection('users').document(user.uid).setData({
  //       'nickName' : nickName,
  //       'phoneNumber' : phoneNumber,
  //       'age' : _age,
  //       'location' : location,
  //       'foods' : chooseFood,
  //       'field' : chooseField,
  //       'tags' : tags,
  //       'displayName' : user.displayName,
  //       'uid' : user.uid,
  //       'photoURL' : user.photoUrl,
  //       'email' : user.email,
  //       'job' : jobController.text,
  //       'lastLoginDate': new DateTime.now()
  //     }).whenComplete((){
  //       MyNavigator.goToHomePage(context, user.uid);
  //     }).catchError((e) => print(e));
  //   });
  //   //여기에서 저장된 데이터들을 DB로 올림
  // }
}
