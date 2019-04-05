import 'dart:io';
import 'dart:async';
import 'package:flute_example/data/song_data.dart';
import 'package:flute_example/pages/now_playing.dart';
import 'package:flute_example/widgets/mp_circle_avatar.dart';
import 'package:flute_example/widgets/mp_inherited.dart';
import 'package:flutter/material.dart';
import './mp_ListItem.dart';
import '../Services/MusicPlayerService.dart';
import 'package:flutter/material.dart';
import '../data/PlayerStateEnum.dart';
import '../utils/LifeCycleEventHandler.dart';
import 'package:media_notification/media_notification.dart';
import 'package:flutter/services.dart';

class MPListView extends StatefulWidget {

  final Stream changeState;
  final StreamController changeNotifier;
  MPListView({this.changeState,this.changeNotifier});
  @override
  _MPListViewState createState() => _MPListViewState();
}

class _MPListViewState extends State<MPListView> {
  StreamSubscription streamSubscription;
  MusicService PLayer;
  WidgetsBindingObserver MediaNotificationPbserver;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamSubscription = widget.changeState.listen((data) => this.changeState(data));


  }

  Future<void> hide() async {
    print('''
=============================================================
               HIDING
=============================================================
''');
    try {
      setState(() {
        MediaNotification.hide();
      });

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
      setState(() {


        MediaNotification.show(title: title, author: author);

      });

    } on PlatformException {

    }
  }

  void changeState(data) {
    print("ListviewChangeState ${data}");
    if(data=="sorted"){
      setState(() {
        print("List view state changed");
      });
    }

    if(data=="EndedSong"){
      setState(() {
        print("List view state changed Song Ended");
      });
    }

  }



  final List<MaterialColor> _colors = Colors.primaries;
  @override
  Widget build(BuildContext context) {
    final rootIW = MPInheritedWidget.of(context);
    SongData songData = rootIW.songData;
    Size screenSize = MediaQuery.of(context).size;
    MusicService PLayer = new MusicService(songData.audioPlayer, songData);
    print(this.PLayer);
    this.PLayer = PLayer;
    print(this.PLayer);
    WidgetsBinding.instance.removeObserver(this.MediaNotificationPbserver);
    PLayer.songData.AppNotifier.add("showMedia");
    PLayer.songData.changeNotifier.stream.listen((data)=>this.changeState(data));



    return new ListView.builder(
      itemCount: PLayer.songData.songs.length,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, int index) {
        var s = PLayer.songData.songs[index];
        final MaterialColor color = _colors[index % _colors.length];
        var artFile =
        s.albumArt == null ? null : new File.fromUri(Uri.parse(s.albumArt));

        return new ListData(
          OnTap:() {
            if(PLayer.Status==PlayerState.playing){
              if(s.id!=PLayer.isPlayingId){
                PLayer.stop().then((stopped){
                  PLayer.play(s).then((onValue){
                    setState(() {
                      PLayer.songData.changeNotifier.add(null);
                    });
                  });
                });
              }
            }else{
              PLayer.play(s).then((startedPlaying){
                setState(() {
                  PLayer.songData.changeNotifier.add(null);
                });
              });

            }
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new NowPlaying(songData, s)));
          },
          margin: EdgeInsets.all(4.0),
          width: screenSize.width,
          title: s.title,
          isPlaying : PLayer.isPlayingId==s.id ?  songData.playerState : null,
          subtitle: "By ${s.artist} ${PLayer.songData.playerState==PLayer.Status} ${PLayer.songData.playerState.toString()}",
          image: artFile!=null ? DecorationImage(image: artFile.existsSync() ? new FileImage(artFile) : AssetImage("assets/back.png"),
              fit: BoxFit.cover): null,
          color: color,
          ActiveCallback: (){
            if(PLayer.Status==PlayerState.playing && PLayer.isPlayingId!=null){
              if(s.id!=PLayer.isPlayingId ){
                print("Not the same song");
                PLayer.stop().then((stopped){
                  PLayer.playById(s.id).then((onValue){
                    setState(() {
                      PLayer.songData.changeNotifier.add(null);
                    });
                  });
                });
              }else{
                PLayer.pause().then((onValue){
                    setState(() {
                      PLayer.songData.changeNotifier.add(null);
                    });
                  });

              }


            }else{
              if(s.id!=PLayer.isPlayingId ){
                print("Not the same song");
                PLayer.stop().then((stopped){
                  PLayer.playById(s.id).then((onValue){
                    setState(() {
                      PLayer.songData.changeNotifier.add(null);
                    });
                  });
                });
              }else{
                PLayer.playById(s.id).then((onValue){
                  setState(() {
                    PLayer.songData.changeNotifier.add(null);
                  });
                });
              }
            }
          },
        );


      },
    );
  }
}


