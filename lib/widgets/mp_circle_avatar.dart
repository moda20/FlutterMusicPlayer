import 'dart:io';
import 'package:flutter/material.dart';

Widget avatar(File f, String title, MaterialColor color) {
  Widget x = new CircleAvatar(
    child: new Icon(
      Icons.music_note,
      color: Colors.white,
    ),backgroundColor: color,
  );
  try{
    Widget y = f!=null ?
    new Image.file(
      f,
      fit: BoxFit.cover,
    ) :
    new CircleAvatar(
      child: new Icon(
        Icons.music_note,
        color: Colors.white,
      ),backgroundColor: color,
    );
    x= y;

  }catch(e){
    print("Errrrrorr finding files");
  }
  return new Material(
    borderRadius: new BorderRadius.circular(20.0),
    elevation: 3.0,
    child: x
  );
}
