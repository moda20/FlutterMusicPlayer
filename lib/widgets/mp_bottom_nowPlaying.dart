import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flute_example/widgets/mp_inherited.dart';
import '../data/PlayerStateEnum.dart';
import './mp_marquee_text.dart';
import '../Services/MusicPlayerService.dart';
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
    print("bottom playing now bar, state changed");
    setState((){
      print("bottom playing now bar, state changed");
    });
  }
  @override
  didUpdateWidget(BottomNowPlaying old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.changeState != old.changeState) {
      streamSubscription.cancel();
      streamSubscription = widget.changeState.listen((_) => this.changeState());
    }
  }
  @override
  dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final rootIW = MPInheritedWidget.of(context);
    Size screenSize = MediaQuery.of(context).size;
    MusicService PLayer = rootIW.songData!=null? new MusicService(rootIW.songData.audioPlayer, rootIW.songData):null;
    return PLayer !=null? new Container(
      decoration: BoxDecoration(
        color: Colors.black26
      ),
      height: PLayer.songData != null && PLayer.songData.currentIndex != -1?60.0:0,
      child : PLayer.songData != null && PLayer.songData.currentIndex != -1
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
              title: PLayer.isPlayingSong.title,
              isPlaying: PLayer.songData.currentIndex != -1
                  ? PLayer.Status
                  : null,
              subtitle:
              "By ${PLayer.isPlayingSong.artist}",
              image: PLayer.isPlayingSong.albumArt != null ? DecorationImage(
                  image: new FileImage(new File.fromUri(Uri.parse(
                      PLayer.isPlayingSong.albumArt))),
                  fit: BoxFit.cover)
                  : null,
              color: Colors.blue,
            )),
        elevation: 20.0,
      )
          : null,
    ): new Container();
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
              new GestureDetector(
                child: image != null
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
                        height: 51.0,
                        width: 51.0,
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
                onTap: (){

                },
              ),
              new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new MarqueeWidget(
                        child: new Text(title,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 1,
                            style: new TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                            )),
                        direction: Axis.horizontal,
                        animationDuration: Duration(milliseconds: title.toString().length*100),
                        pauseDuration: Duration(milliseconds: title.toString().length*20),
                        backDuration: Duration(milliseconds: title.toString().length*20),
                      ),
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



