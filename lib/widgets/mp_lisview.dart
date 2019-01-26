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

class MPListView extends StatefulWidget {

  final Stream changeState;
  final StreamController changeNotifier;
  MPListView({this.changeState,this.changeNotifier});
  @override
  _MPListViewState createState() => _MPListViewState();
}

class _MPListViewState extends State<MPListView> {
  StreamSubscription streamSubscription;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamSubscription = widget.changeState.listen((data) => this.changeState(data));
  }


  void changeState(data) {
    print(data);
    if(data=="sorted"){
      setState(() {
        print("List view state changed");
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
            PLayer.songData.setCurrentIndex(PLayer.songData.CurrentIndexOfSong(s));
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new NowPlaying(songData, s)));
          },
          margin: EdgeInsets.all(4.0),
          width: screenSize.width,
          title: s.title,
          isPlaying : PLayer.isPlayingId==s.id ?  songData.playerState : null,
          subtitle: "By ${s.artist} ${PLayer.isPlayingId==s.id}",
          image: artFile!=null ? DecorationImage(image:  new FileImage(artFile) ,
              fit: BoxFit.cover): null,
          color: color,
          ActiveCallback: (){
            if(PLayer.Status==PlayerState.playing){
              if(s.id!=PLayer.isPlayingId){
                PLayer.stop().then((stopped){
                  PLayer.play(s).then((onValue){
                    widget.changeNotifier.add(null);
                    setState(() {

                    });
                  });
                });
              }else{
                PLayer.pause().then((onValue){
                    widget.changeNotifier.add(null);
                    setState(() {

                    });
                  });

              }


            }else{
              PLayer.play(s).then((startedPlaying){
                setState(() {
                });
                widget.changeNotifier.add(null);
              });

            }
          },
        );


      },
    );
  }
}

/*

class MPListView extends StatelessWidget {
  final List<MaterialColor> _colors = Colors.primaries;
  @override
  Widget build(BuildContext context) {
    final rootIW = MPInheritedWidget.of(context);
    SongData songData = rootIW.songData;
    Size screenSize = MediaQuery.of(context).size;
    return new ListView.builder(
      itemCount: songData.songs.length,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, int index) {

        var s = songData.songs[index];
        final MaterialColor color = _colors[index % _colors.length];
        var artFile =
            s.albumArt == null ? null : new File.fromUri(Uri.parse(s.albumArt));



        return new ListData(
            OnTap:() {
              songData.setCurrentIndex(index);
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new NowPlaying(songData, s)));
            },
            margin: EdgeInsets.all(4.0),
            width: screenSize.width,
            title: s.title,
            isPlaying : songData.currentIndex!=-1 && s.id == songData.songs[songData.currentIndex].id ?  songData.playerState : null,
            subtitle: "By ${s.artist}",
            image: artFile!=null ? DecorationImage(image:  new FileImage(artFile) ,
                fit: BoxFit.cover): null,
           color: color,
        );


      },
    );
  }
}
*/
