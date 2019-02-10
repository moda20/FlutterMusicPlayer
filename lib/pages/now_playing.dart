import 'dart:async';
import 'dart:ui';
import 'package:flute_example/data/song_data.dart';
import 'package:flute_example/widgets/mp_album_ui.dart';
import 'package:flute_example/widgets/mp_blur_filter.dart';
import 'package:flute_example/widgets/mp_blur_widget.dart';
import 'package:flute_example/widgets/mp_control_button.dart';
import 'package:flute_example/widgets/mp_inherited.dart';
import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';

import '../data/PlayerStateEnum.dart';
import '../Services/MusicPlayerService.dart';
class NowPlaying extends StatefulWidget {
  final Song _song;
  final SongData songData;
  final bool nowPlayTap;
  MusicService audioPlayer ;
  NowPlaying(this.songData, this._song, {this.nowPlayTap}){
    this.audioPlayer = new MusicService(this.songData.audioPlayer, this.songData,overwriteHandlers: true);
  }

  @override
  _NowPlayingState createState() => new _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  MusicService audioPlayer ;
  Duration duration;
  Duration position;
  PlayerState playerState;
  Song song;
  StreamSubscription streamSubscription;





  get isPlaying => this.audioPlayer.Status == PlayerState.playing;
  get isPaused => this.audioPlayer.Status == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  @override
  initState() {
    super.initState();

    initPlayer();

  }

  @override
  void dispose() {
    super.dispose();

    print("Disposed Now Playing ${audioPlayer}");
  }

  void onComplete() {
    print("onComleteDone");
    try{
      setState(()  {
        playerState = PlayerState.stopped ;
        audioPlayer.Status = playerState;
      });
    }catch(e){
      print(e);
    }
    next();
  }

  initPlayer() async {

    if (audioPlayer == null) {
      print("setting the new player");
      audioPlayer = widget.audioPlayer;
    }
    streamSubscription = audioPlayer.songData.changeNotifier.stream.listen((data){
      if(data =="EndedSong"){
        print("EndedSong => RefreshingWidget");
        print("Old song = ${audioPlayer.isPlayingSong.title}");
        setState(() {

        });
        print("Old song = ${audioPlayer.isPlayingSong.title}");
      }

    });
    setState(() {
      song =  audioPlayer.isPlayingSong;
      if(audioPlayer.Status != PlayerState.playing){
        /*play(song);*/
        print("gonna play teh song after going to now playing");
      }
    });

    this.audioPlayer.setDurationHandler((d){
      print(" duration ${d}");
      setState(() {
        duration = d;
      });
    });

    this.audioPlayer.setPositionHandler((p) {
      setState(() {
        position = p;
      });
    });

    setState(() {

    });
    this.audioPlayer.setOnCompleteHandler(() {
      onComplete();
      setState(() {
        position = duration;
      });
    });

   /*
    this.audioPlayer.MusicPlayer.setErrorHandler((msg) {
      print("Error happened");
      setState(() {
        playerState = PlayerState.stopped;
        widget.songData.playerState= playerState;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });*/


  }



  Future play(Song s) async {
    if (s != null) {
      audioPlayer.play(s).then((played){
        setState(() {

        });
      });
    }
  }

  Future pause() async {
    audioPlayer.pause().then((played){
      setState(() {

      });
    });
  }

  Future stop() async {
    audioPlayer.stop().then((played){
      setState(() {

      });
    });
  }

  Future next() async {
    audioPlayer.next().then((played){

      setState(() {

      });
    });
  }

  Future prev() async {
    audioPlayer.prev().then((played){
      setState(() {

      });
    });
  }

  Future mute(bool muted) async {
    audioPlayer.mute(muted).then((played){
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {


/*  if(audioPlayer == null){
      audioPlayer = widget.audioPlayer;
    }*/
    Widget _buildPlayer() => new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(mainAxisSize: MainAxisSize.min, children: [
          new Column(
            children: <Widget>[
              new Text(
                audioPlayer.isPlayingSong.title,
                style: Theme.of(context).textTheme.headline,
              ),
              new Text(
                audioPlayer.isPlayingSong.artist,
                style: Theme.of(context).textTheme.caption,
              ),
              new Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
              )
            ],
          ),
          new Row(mainAxisSize: MainAxisSize.min, children: [
            new ControlButton(Icons.skip_previous, () => prev()),
            new ControlButton(audioPlayer.Status==PlayerState.playing ? Icons.pause : Icons.play_arrow,
                audioPlayer.Status==PlayerState.playing ? () => pause() : () => play(audioPlayer.isPlayingSong)),
            new ControlButton(Icons.skip_next, () => next()),
          ]),
          duration == null
              ? new Container()
              : new Slider(
                  value: position?.inMilliseconds?.toDouble() ?? 0,
                  onChanged: (double value) {

                    audioPlayer.MusicPlayer.seek((value / 1000).roundToDouble());
                  },
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble()),
          new Row(mainAxisSize: MainAxisSize.min, children: [
            new Text(
                position != null
                    ? "${positionText ?? ''} / ${durationText ?? ''}"
                    : duration != null ? durationText : '',
                // ignore: conflicting_dart_import
                style: new TextStyle(fontSize: 24.0))
          ]),
          new Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new IconButton(
                  icon: audioPlayer.isMuted
                      ? new Icon(
                          Icons.headset,
                          color: Theme.of(context).unselectedWidgetColor,
                        )
                      : new Icon(Icons.headset_off,
                          color: Theme.of(context).unselectedWidgetColor),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    mute(!isMuted);
                  }),
              // new IconButton(
              //     onPressed: () => mute(true),
              //     icon: new Icon(Icons.headset_off),
              //     color: Colors.cyan),
              // new IconButton(
              //     onPressed: () => mute(false),
              //     icon: new Icon(Icons.headset),
              //     color: Colors.cyan),
            ],
          ),
        ]));

    var playerUI = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          new AlbumUI(audioPlayer.isPlayingSong, duration, position),
          new Material(
            child: _buildPlayer(),
            color: Colors.transparent,
          ),
        ]);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Now Playing"),

      ),
      body: new Container(
        color: Theme.of(context).backgroundColor,
        child: new Stack(
          fit: StackFit.expand,
          overflow: Overflow.visible,
          children: <Widget>[blurWidget(audioPlayer.isPlayingSong), blurFilter(), playerUI],
        )
      ),
    );
  }



}
