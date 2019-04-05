import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import '../Services/MusicPlayerService.dart';
import '../widgets/mp_songlist_swipe.dart';

class AlbumUI extends StatefulWidget {
  final Song song;
  final Duration position;
  final Duration duration;
  final List<Song> songs;
  final MusicService songService;
  final dynamic OnNext;
  final dynamic OnPrevious;

  AlbumUI(this.song, this.duration, this.position, this.songs, this.songService,
      this.OnNext, this.OnPrevious);

  @override
  AlbumUIState createState() {
    return new AlbumUIState();
  }
}

class AlbumUIState extends State<AlbumUI> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController animationController;

  @override
  initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 1));
    animation = new CurvedAnimation(
        parent: animationController, curve: Curves.elasticOut);
    animation.addListener(() => this.setState(() {}));
    animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Song song = MPInheritedWidget.of(context).songData.nextSong;
    var f = widget.song.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(widget.song.albumArt));

    var myHero = new Hero(
      tag: widget.song.title,
      child: new Material(
          borderRadius: new BorderRadius.circular(5.0),
          elevation: 5.0,
          child: f != null
              ? new Image.file(
                  f,
                  fit: BoxFit.cover,
                  height: 250.0,
                  gaplessPlayback: true,
                )
              : new Image.asset(
                  "assets/music_record.jpeg",
                  fit: BoxFit.cover,
                  height: 250.0,
                  gaplessPlayback: false,
                )),
    );
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return new SizedBox.fromSize(
      size: new Size(width, width),
      child: new Stack(
        children: <Widget>[
          new mp_songlist_swipe(
              widget.songService.songData.songs,
              widget.songService.songData.currentIndex,
              widget.OnNext,
              widget.OnPrevious),
        ],
      ),
    );
  }

  void OnNext() {}
}
