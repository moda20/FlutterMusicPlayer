import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:flute_music_player/flute_music_player.dart';
import '../data/song_data.dart';
import '../data/PlayerStateEnum.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:media_notification/media_notification.dart';
import 'package:media_notification/media_notification.dart';
import 'package:flutter/services.dart';
import '../utils/LifeCycleEventHandler.dart';


class MusicService {

  static  MusicService _instance = null;

  /*MusicService.internal();*/

  MusicService.private(MusicPlayer, songData, {overwriteHandlers = false}) {
    this.songData = songData;
    this.MusicPlayer = this.songData.audioPlayer;
    this.isMuted = false;
    this.isPlayingSong =
    this.songData.currentIndex >= 0 ? this.songData.songs[this.songData
        .currentIndex] : null;
    this.isPlayingId =
    this.isPlayingSong != null ? this.isPlayingSong.id : null;
    this.Status = this.songData.playerState;
    if (songData != null) {
      changeNotifier = this.songData.changeNotifier;
    }
    this.overwriteHandlers = overwriteHandlers;
    if (this.overwriteHandlers != true) {
      if (this.MusicPlayer.completionHandler == null) {
        this.MusicPlayer.setCompletionHandler(() {
          stop().then((data) {
            next().then((data) {
              print("using the automatic completition handler");
              this.songData.changeNotifier.add("EndedSong");
            });
          });
        });
      }
    }

    //initializing the mediaNotifications

    /*Future<void> MediaNotificationState(data,MusicService PLayer) async {
      print('''
=============================================================
              SHOULD SEND NOW
=============================================================
''');
      try {


      } on Exception {
        print('''
=============================================================
               ${Exception}
=============================================================
''');
      }
    }

    this.MediaNotificationPbserver = new LifecycleEventHandler(
        resumeCallBack:  MediaNotificationState("showMedia", this.PLayer) ,
        suspendingCallBack: MediaNotificationState("hideMedia", this.PLayer)
    );
    WidgetsBinding.instance.addObserver(
        this.MediaNotificationPbserver
    );
*/
  }

  factory MusicService(MusicPlayer, songData, {overwriteHandlers = false}) {
    if(_instance==null){
      _instance = MusicService.private(MusicPlayer, songData, overwriteHandlers: overwriteHandlers) ;
    }
    return _instance;
  }

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
  StreamController changeNotifier;

  bool overwriteHandlers = false;

  void setDurationHandler(TimeChangeHandler handler) {
    durationHandler = handler;

    if (this.overwriteHandlers == true) {
      print("current duration handler == ${this.MusicPlayer
          .durationHandler} / our handler == ${durationHandler != null}");
      if (durationHandler != null) {
        this.MusicPlayer.setDurationHandler((p) {
          print("setting our duration handler");

          durationHandler(p);
        });
      } else {
        print("not going to duration handler");
      }
    }
  }

  void setPositionHandler(TimeChangeHandler handler) {
    positionHandler = handler;
    if (this.overwriteHandlers == true) {
      print("current position handler == ${this.MusicPlayer
          .positionHandler} / our handler == ${positionHandler != null}");

      if (positionHandler != null) {
        this.MusicPlayer.setPositionHandler((p) {
          /*print("position from service  ${positionHandler}");*/

          if (positionHandler != null) {
            positionHandler(p);
          }
        });
      } else {
        print("not going to position handler");
      }
    }
  }

  void setOnCompleteHandler(VoidCallback handler) {
    completionHandler = handler;
    print("current complete handler == ${this.MusicPlayer
        .completionHandler} / our handler == ${completionHandler != null}");
    if (this.overwriteHandlers == true) {
      print("setting out complete handler");
      this.MusicPlayer.setCompletionHandler(() {
        this.songData.changeNotifier.add("EndedSong");
        handler();
      });
    }
  }

  void setOnStartHandler(TimeChangeHandler handler) {
    startHandler = handler;
    /*if(this.overwriteHandlers ==true){
      SetHandlers();
    }*/
  }

  void etOnErrorHandler(ErrorHandler handler) {
    errorHandler = handler;
    if (this.overwriteHandlers == true) {
      this.MusicPlayer.setErrorHandler((msg) {
        this.songData.changeNotifier.addError(msg);
        Status = PlayerState.stopped;
        /*durationHandler = new Duration(seconds: 0);
      positionHandler = new Duration(seconds: 0);*/
      });
    }
  }




  PlayerState get Status => _Status;

  set Status(PlayerState value) {
    if (_Status != null) {
      songData.playerState = value;
    }
    _Status = value;
  }

  Future play(Song s) async {
    if (s != null) {
      final result = await MusicPlayer.play(s.uri, isLocal: true);
      print("CLICKED ON PLAY ${s.title} / ${result}");
      if (result == 1) {
        Status = PlayerState.playing;
        songData.playerState = Status;
        print("Stting the status to playing");
        isPlayingSong = s;
        this.isPlayingId =
        this.isPlayingSong != null ? this.isPlayingSong.id : null;
        songData.setCurrentIndex(songData.CurrentIndexOfSong(s));
      }
    }


  }

  Future playById(int id) async {
    if (id != null && id > 0) {
      Song s = songData.songs[songData.songs.indexWhere((x) => x.id == id)];
      final result = await MusicPlayer.play(s.uri, isLocal: true);
      if (result == 1) {
        Status = PlayerState.playing;
        songData.playerState = Status;
        isPlayingSong = s;
        this.isPlayingId =
        this.isPlayingSong != null ? this.isPlayingSong.id : null;
        songData.setCurrentIndex(songData.CurrentIndexOfSong(s));
      }
    }
  }

  Future pause() async {
    final result = await MusicPlayer.pause();
    if (result == 1) {
      Status = PlayerState.paused;
      songData.playerState = Status;
    }
  }

  Future stop() async {
    final result = await MusicPlayer.stop();
    if (result == 1) {
      Status = PlayerState.stopped;
      songData.playerState = Status;
      print("Stting the status to stopped");
    }
  }

  Future next() async {
    await stop().then((data) {
      return play(this.songData.nextSong);
    }
    );
  }

  Future prev() async {
     await stop().then((data) {
       return play(this.songData.prevSong);
    }
    );
  }

  Future mute(bool muted) async {
    final result = await MusicPlayer.mute(muted);
    if (result == 1) {
      isMuted = muted;
    }
  }


  Map<String, Map<String, dynamic>> GetAlbums() {
    List<Map<String, dynamic>> FinalList = new List();
    Map<String, Map<String, dynamic>> albums = new Map();
    for (var i = 0; i < this.songData.length; i++) {
      if (albums.containsKey(this.songData.songs[i].album)) {
        albums[this.songData.songs[i].album]["songs"].add(songData.songs[i]);
        albums[this.songData.songs[i].album]["title"] = songData.songs[i].album;
        albums[this.songData.songs[i].album]["thumb"] =
            songData.songs[i].albumArt;
        albums[this.songData.songs[i].album]["artist"] =
            songData.songs[i].artist;
      } else {
        albums[this.songData.songs[i].album] = {};
        albums[this.songData.songs[i].album]["songs"] = [];
        albums[this.songData.songs[i].album]["songs"].add(songData.songs[i]);
        albums[this.songData.songs[i].album]["title"] = songData.songs[i].album;
        albums[this.songData.songs[i].album]["thumb"] =
            songData.songs[i].albumArt;
        albums[this.songData.songs[i].album]["artist"] =
            songData.songs[i].artist;
      }
    }
    return albums;
  }

  Future<void> hide() async {
    try {
      await MediaNotification.hide();

    } on PlatformException {

    }
  }

  Future<void> show(title, author) async {
    try {
      await MediaNotification.show(title: title, author: author);

    } on PlatformException {

    }
  }

  void SetMediaHandlers(){
    MediaNotification.setListener('play', () {
      if(this.isPlayingSong!=null){
        this.play(this.isPlayingSong).then(
                (data){
              this.songData.changeNotifier.add(null);
              print('played from notif');
            }
        );
      }else{
        print("Playing Song Is null will play random song");
        this.play(this.songData.randomSong).then(
                (data){
              print('played from notif');
              this.songData.changeNotifier.add(null);
            }
        );
      }

    });

    MediaNotification.setListener('pause', () {
      this.pause().then((data){
        this.songData.changeNotifier.add(null);
      });
    });

    MediaNotification.setListener('next', () {
      this.next().then(
              (data){
            print('next from notif');
            show(this.isPlayingSong.title,this.isPlayingSong.artist);
            this.songData.changeNotifier.add(null);

          }
      );
    });

    MediaNotification.setListener('prev', () {
      this.prev().then(
              (data){
            print('prev from notif');
            show(this.isPlayingSong.title,this.isPlayingSong.artist);
            this.songData.changeNotifier.add(null);

          }
      );
    });

    MediaNotification.setListener('select', () {
      print("select");
    });
  }
}

