import 'package:flutter/material.dart';
import 'package:shopping_mall/home.dart';
import 'package:shopping_mall/login.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Shopping Mall',
      theme: new ThemeData(primaryColor: Colors.grey[300]),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      onGenerateRoute: _getRoute,
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => new Login()
      },
      home: Home(),
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => Login(),
      fullscreenDialog: true,
    );
  }
}
