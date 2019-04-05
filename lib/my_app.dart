import 'package:flute_example/data/song_data.dart';
import 'package:flute_example/pages/root_page.dart';
import 'package:flute_example/widgets/mp_inherited.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import './data/SongDatabase.dart';
import 'package:media_notification/media_notification.dart';
import 'package:flutter/services.dart';
import './Services/MusicPlayerService.dart';
import './utils/LifeCycleEventHandler.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp>  with WidgetsBindingObserver{
  SongData songData;
  bool _isLoading = true;
  SongDatabase songDatabase;
  MusicService Player;
var status;
  @override
  void initState() {
    super.initState();
    initPlatformState();

  }

  @override
  void dispose() {
    super.dispose();
    songData.audioPlayer.stop();
    hide();
  }


 /* @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      switch(state){
        case AppLifecycleState.paused :{
          print("paued");
          if(Player.isPlayingSong!=null){
            show(Player.isPlayingSong.title, Player.isPlayingSong.artist).then(
                    (data){
                  print("Showed from init");
                }
            );
          }
          break;
        }
        case AppLifecycleState.inactive :{
          print("Inactive");
          break;
        }
        case AppLifecycleState.resumed :{
          print("Resumed");
          hide();
          break;
        }
        case AppLifecycleState.suspending :{
          print("suspending");
          break;
        }
      }
    });

  }*/

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/songdb.json');
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    _isLoading = true;

    var songs;

    File file = await _localFile;
    if(file.existsSync()){
      songDatabase = new SongDatabase();
      songDatabase = await songDatabase.ReadDatabase();
      print("Parsed Songs from file");
    }else{
      try {
        songs = await MusicFinder.allSongs();
        print("Parsed Songs from Storage");
        songData = new SongData(songDatabase, songs);
        songDatabase = new SongDatabase(
          OriginalSongData: songData,
        );
        songDatabase.initiateOriginalToLocalDatabaseTransfer();
        songDatabase.SaveDatatabse();
      } catch (e) {
        print(e);
        print("Failed to get songs: '${e.message}'.");
      }
    }



    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      songData = new SongData(songDatabase,songs);
      _isLoading = false;
    });
    /*Player = MusicService(songData.audioPlayer, songData);
    WidgetsBinding.instance.addObserver(
        new LifecycleEventHandler(
            resumeCallBack:  show(Player.isPlayingSong!=null?Player.isPlayingSong.title:"", Player.isPlayingSong!=null?Player.isPlayingSong.artist:""),
            suspendingCallBack: hide()
        )
    );*/
  }

  @override
  Widget build(BuildContext context) {
    InitMediaState(songData);
    return new MPInheritedWidget(songData, _isLoading, new RootPage(),songDatabase);

  }

  InitMediaState(SongData Data){

    if(Data==null){
      return;
    }


    MediaNotification.setListener('pause', () {
      Player.pause().then(
          (data){
            print('paused from notif');
          }
      );
      setState(() => status = 'pause');

    });




  }

  Future<void> hide() async {
    print('''
=============================================================
               HIDING
=============================================================
''');
    try {
      await MediaNotification.hide();
      setState(() => status = 'hidden');
    } on PlatformException {

    }
  }

  Future<void> show(title, author) async {
    print('''
=============================================================
               SHOWING
=============================================================
''');
    try {
      await MediaNotification.show(title: title, author: author);
      setState(() => status = 'play');
    } on PlatformException {

    }
  }
}
