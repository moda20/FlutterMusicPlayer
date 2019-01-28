import 'dart:ui';

import 'package:flute_music_player/flute_music_player.dart';
import '../data/song_data.dart';
import '../data/PlayerStateEnum.dart';
import 'dart:async';
class MusicService {
  MusicFinder MusicPlayer;
  bool isMuted;
  Song isPlayingSong;
  PlayerState _Status;
  SongData songData;
  int isPlayingId;
  TimeChangeHandler durationHandler;
  TimeChangeHandler positionHandler;
  TimeChangeHandler startHandler;
  VoidCallback completionHandler;
  ErrorHandler errorHandler;
  StreamController changeNotifier ;
  bool overwriteHandlers = false;

  void setDurationHandler(TimeChangeHandler handler) {

    durationHandler = handler;

    if(this.overwriteHandlers ==true){
      print("current duration handler == ${this.MusicPlayer.durationHandler} / our handler == ${durationHandler!=null}");
      if( durationHandler !=null){
        this.MusicPlayer.setDurationHandler((p){
          print("setting our duration handler");

            durationHandler(p);


        });
      }else{
        print("not going to duration handler");
      }
    }
  }

  void setPositionHandler(TimeChangeHandler handler) {
    positionHandler = handler;
    if(this.overwriteHandlers ==true){

      print("current position handler == ${this.MusicPlayer.positionHandler} / our handler == ${positionHandler!=null}");

      if( positionHandler != null) {
        this.MusicPlayer.setPositionHandler((p) {
          /*print("position from service  ${positionHandler}");*/

          if (positionHandler != null) {
            positionHandler(p);
          }
        });
      }else{
        print("not going to position handler");
      }
    }
  }

  void setOnCompleteHandler(VoidCallback handler){


    completionHandler = handler;
    print("current complete handler == ${this.MusicPlayer.completionHandler} / our handler == ${completionHandler!=null}");
    if(this.overwriteHandlers ==true){
      this.MusicPlayer.setCompletionHandler(() {
        this.songData.changeNotifier.add("EndedSong");
        handler();
      });
    }
  }

  void setOnStartHandler(TimeChangeHandler handler){
    startHandler = handler;
    /*if(this.overwriteHandlers ==true){
      SetHandlers();
    }*/
  }

  void etOnErrorHandler(ErrorHandler handler){
    errorHandler = handler;
    if(this.overwriteHandlers ==true){
      this.MusicPlayer.setErrorHandler((msg) {
        this.songData.changeNotifier.addError(msg);
        Status = PlayerState.stopped;
        /*durationHandler = new Duration(seconds: 0);
      positionHandler = new Duration(seconds: 0);*/
      });
    }
  }

  MusicService(MusicPlayer,songData,{overwriteHandlers=false}){

    this.songData = songData;
    this.MusicPlayer=this.songData.audioPlayer;
    this.isMuted = false;
    this.isPlayingSong = this.songData.currentIndex>=0?this.songData.songs[this.songData.currentIndex]:null;
    this.isPlayingId= this.isPlayingSong!=null?this.isPlayingSong.id:null;
    this.Status=this.songData.playerState;
    if(songData!=null){
      changeNotifier = this.songData.changeNotifier;
    }
    this.overwriteHandlers=overwriteHandlers;
    /*this.MusicPlayer.setCompletionHandler((){
      stop().then((data){
        next().then((data){
          this.songData.changeNotifier.add("EndedSong");
        });
      });

    });*/


  }


  PlayerState get Status => _Status;

  set Status(PlayerState value) {
    if(_Status!=null){
      songData.playerState=value;
    }
    _Status = value;
  }

  Future play(Song s) async {

    if (s != null) {
      final result = await MusicPlayer.play(s.uri, isLocal: true);
      print("CLICKED ON PLAY ${s.title} / ${result}");
      if(result == 1){
        Status = PlayerState.playing;
        songData.playerState= Status;
        isPlayingSong=s;
        this.isPlayingId= this.isPlayingSong!=null?this.isPlayingSong.id:null;
        songData.setCurrentIndex(songData.CurrentIndexOfSong(s));
      }
    }
  }

  Future playById(int id) async {
    if (id != null && id >0) {
      Song s = songData.songs[songData.songs.indexWhere((x) => x.id==id)];
      final result = await MusicPlayer.play( s.uri, isLocal: true);
      if(result == 1){
        Status = PlayerState.playing;
        songData.playerState= Status;
        isPlayingSong=s;
        this.isPlayingId= this.isPlayingSong!=null?this.isPlayingSong.id:null;
        songData.setCurrentIndex(songData.CurrentIndexOfSong(s));
      }
    }
  }

  Future pause() async {
    final result = await MusicPlayer.pause();
    if(result == 1){
      Status = PlayerState.paused;
      songData.playerState= Status;
    }
  }

  Future stop() async {
    final result = await MusicPlayer.stop();
    if(result == 1){
      Status = PlayerState.stopped;
      songData.playerState= Status;
    }
  }

  Future next() async {
    stop();
    play(this.songData.nextSong);
  }

  Future prev() async {
    stop();
    play(this.songData.prevSong);
  }

  Future mute(bool muted) async {
    final result = await MusicPlayer.mute(muted);
    if(result==1){
      isMuted=muted;
    }
  }



}