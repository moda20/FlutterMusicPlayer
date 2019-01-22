import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flute_example/widgets/mp_inherited.dart';
import '../data/PlayerStateEnum.dart';
import '../pages/root_page.dart';
class BottomNowPlaying extends StatefulWidget {

  @override
  BottomNowPlayingState createState() => BottomNowPlayingState();

  final VoidCallback onTap ;
  final Stream changeState;

  BottomNowPlaying({Key key,this.onTap,this.changeState}): super(key: key);
}

class BottomNowPlayingState extends State<BottomNowPlaying> {

  StreamSubscription streamSubscription;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamSubscription = widget.changeState.listen((_) => this.changeState());
  }

  void changeState(){
    setState((){
      print("STTTTTTTTaete");
    });

  }
 /* @override
  didUpdateWidget(BottomNowPlaying old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.changeState != old.changeState) {
      streamSubscription.cancel();
      streamSubscription = widget.changeState.listen((_) => this.changeState());
    }
  }*/
  @override
  dispose() {
    super.dispose();
    /*streamSubscription.cancel();*/
  }

  @override
  Widget build(BuildContext context) {
    final rootIW = MPInheritedWidget.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return new Container(
      decoration: BoxDecoration(
        color: Colors.black26
      ),
      height: rootIW.songData != null && rootIW.songData.currentIndex != -1?60.0:0,
      child : rootIW.songData != null && rootIW.songData.currentIndex != -1
          ? new Material(
        child: new Container(
            decoration: BoxDecoration(
                color: Colors.white.withAlpha(6)
            ),
            height: 60.0,
            child: _buildBottomNavigationBar(
              OnTap: () {
                widget.onTap();

                /*goToNowPlaying(
                rootIW.songData.songs[
                (rootIW.songData.currentIndex == null ||
                    rootIW.songData.currentIndex < 0)
                    ? 0
                    : rootIW.songData.currentIndex],
                nowPlayTap: true,
              )*/
              },
              margin: EdgeInsets.all(1.0),
              width: screenSize.width,
              title: rootIW
                  .songData.songs[rootIW.songData.currentIndex].title,
              isPlaying: rootIW.songData.currentIndex != -1
                  ? rootIW.songData.playerState
                  : null,
              subtitle:
              "By ${rootIW.songData.songs[rootIW.songData.currentIndex].artist}",
              image: rootIW
                  .songData
                  .songs[rootIW.songData.currentIndex]
                  .albumArt !=
                  null
                  ? DecorationImage(
                  image: new FileImage(new File.fromUri(Uri.parse(
                      rootIW
                          .songData
                          .songs[rootIW.songData.currentIndex]
                          .albumArt))),
                  fit: BoxFit.cover)
                  : null,
              color: Colors.blue,
            )),
        elevation: 10.0,
      )
          : null,
    );
  }




  Widget _buildBottomNavigationBar(
      {margin, width, title, isPlaying, subtitle, image, color, OnTap}) {
    return (new GestureDetector(
        onTap: () {
          OnTap();
        },
        child: new Container(
          alignment: Alignment.center,
          margin: margin,
          width: width,
          height: 60.0,
          decoration: new BoxDecoration(
            color: Colors.transparent,
          ),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              image != null
                  ? new Container(
                  margin: new EdgeInsets.only(
                      left: 10.0, top: 5.0, bottom: 5.0, right: 10.0),
                  width: 50.0,
                  height: 50.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle, image: image),
                  child: isPlaying != null
                      ? new BackdropFilter(
                    filter: new ImageFilter.blur(
                        sigmaX: 4.0, sigmaY: 4.0),
                    child: new Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: new BoxDecoration(
                          color:
                          Colors.grey.shade500.withOpacity(0.01),
                          shape: BoxShape.circle),
                      child: new Icon(
                        isPlaying == PlayerState.playing
                            ? Icons.pause
                            : isPlaying == PlayerState.stopped
                            ? Icons.play_arrow
                            : Icons.play_arrow,
                        color: Colors.grey.shade500,
                        size: 35.0,
                      ),
                      alignment: Alignment(0.0, 0.0),
                    ),
                  )
                      : new Container())
                  : new Container(
                margin: new EdgeInsets.only(
                    left: 10.0, top: 5.0, bottom: 5.0, right: 10.0),
                width: 50.0,
                height: 50.0,
                child: new CircleAvatar(
                  child: isPlaying != null
                      ? new Icon(
                    isPlaying == PlayerState.playing
                        ? Icons.pause
                        : isPlaying == PlayerState.stopped
                        ? Icons.play_arrow
                        : Icons.play_arrow,
                    color: Colors.grey.shade500,
                    size: 35.0,
                  )
                      : new Icon(
                    Icons.music_note,
                    color: Colors.white,
                  ),
                  backgroundColor: color,
                ),
              ),
              new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(title,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 1,
                          style: new TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          )),
                      new Padding(
                        padding: new EdgeInsets.only(top: 2.5),
                        child: new Text(
                          subtitle,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 1,
                          style: new TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w300),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        )));
  }
}



