import 'package:flutter/material.dart';
import 'package:flute_example/my_app.dart';
import 'package:flute_example/utils/themes.dart';
import 'package:media_notification/media_notification.dart';
void main() => runApp(new MyMaterialApp());

class MyMaterialApp extends StatefulWidget {
  @override
  MyMaterialAppState createState() {
    return new MyMaterialAppState();
  }
}

class MyMaterialAppState extends State<MyMaterialApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false, theme: darkTheme, home: new MyApp());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("##########GOIN TO DISPOOSSS NOWWWW #########");
      MediaNotification.hide();
    super.dispose();

  }
}
