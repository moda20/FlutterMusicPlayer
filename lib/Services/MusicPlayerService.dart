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

  void setDurationHandler(TimeChangeHandler handler) {
    durationHandler = handler;
  }

  void setPositionHandler(TimeChangeHandler handler) {
    positionHandler = handler;
  }

  void setOnCompleteHandler(VoidCallback handler){
    completionHandler = handler;
  }

  void setOnStartHandler(TimeChangeHandler handler){
    startHandler = handler;
  }

  void etOnErrorHandler(ErrorHandler handler){
    errorHandler = handler;
  }

  MusicService(MusicPlayer,songData){

    this.songData = songData;
    this.MusicPlayer=this.songData.audioPlayer;
    this.isMuted = false;
    this.isPlayingSong = this.songData.currentIndex>=0?this.songData.songs[this.songData.currentIndex]:null;
    this.isPlayingId= this.isPlayingSong!=null?this.isPlayingSong.id:null;
    this.Status=this.songData.playerState;
    if(songData!=null){
      changeNotifier = this.songData.changeNotifier;
    }

    this.MusicPlayer.setDurationHandler((p){
      print("duration from service  ${p}");
        if(durationHandler != null){
          durationHandler(p);
        }
    });

    this.MusicPlayer.setPositionHandler((p){

        if(positionHandler != null){
          print("position from service  ${p}");
          positionHandler(p);
        }
    });

    this.MusicPlayer.setCompletionHandler(completionHandler);

    /*void setStartHandler(VoidCallback callback) {
      startHandler = callback;
    }

    void setCompletionHandler(VoidCallback callback) {
      completionHandler = callback;
    }

    void setErrorHandler(ErrorHandler handler) {
      errorHandler = handler;
    }*/




    /*this.MusicPlayer.setCompletionHandler(() {
      this.songData.changeNotifier.add("EndedSong");
      currentPosition = currentDuration;
    });

    this.MusicPlayer.setErrorHandler((msg) {
      this.songData.changeNotifier.addError(msg);
      Status = PlayerState.stopped;
      currentDuration = new Duration(seconds: 0);
      currentPosition = new Duration(seconds: 0);
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