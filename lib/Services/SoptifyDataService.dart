import 'package:spotify/spotify_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:convert';


class SpotifyService{



  String _clientID ="bd6f94aa356049f69463d86083562522";
  String _clienSecret = "5cd7f02aa3754fb785e07264cbb321bf";
  SpotifyApi Spotify = null;
  String redirectUrl ="Http://ExtraComs.com";
  set clientID(String value) {
    _clientID = value;
  }


  String get clientID => _clientID;

  getSpotifyArtist(clientId,clientSecret,artistkey) async{
    var credentials = new SpotifyApiCredentials(clientId, clientSecret);
    this.Spotify = new SpotifyApi(credentials);
    //'0OdUWJ0sBjDrqHygGUXeCF'
    var artist = await this.Spotify.artists.get("0OdUWJ0sBjDrqHygGUXeCF");

    return artist;
  }

  getMe(){
    this.Spotify.users.me().then((user){
      print(user.displayName);
    });
  }

  String get clienSecret => _clienSecret;

  set clienSecret(String value) {
    _clienSecret = value;
  }


  promptUsertoLogin(url,context){
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((String url) {

      if(Uri.decodeFull(url).contains(this.redirectUrl)){
        print(url);
      }
    });
    flutterWebviewPlugin.launch(url,
      rect: new Rect.fromLTWH(
        10.0,
        10.0,
        MediaQuery.of(context).size.width-20.0,
        MediaQuery.of(context).size.height-20.0,
      ),
    );


  }


}