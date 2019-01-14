import 'package:flute_example/pages/now_playing.dart';
import 'package:flute_example/widgets/mp_inherited.dart';
import 'package:flute_example/widgets/mp_lisview.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import '../widgets/mp_ListItem.dart';
import 'dart:io';
import 'dart:ui';
import '../data/PlayerStateEnum.dart';
import '../widgets/mp_animatedFab.dart';
class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _loginFormKey= new GlobalKey<FormState>(debugLabel: '_loginFormKey');
    final rootIW = MPInheritedWidget.of(context);
    Size screenSize = MediaQuery.of(context).size;
    //Goto Now Playing Page
    void goToNowPlaying(Song s, {bool nowPlayTap: false}) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new NowPlaying(
                    rootIW.songData,
                    s,
                    nowPlayTap: nowPlayTap,
                  )));
    }

    //Shuffle Songs and goto now playing page
    void shuffleSongs() {
      goToNowPlaying(rootIW.songData.randomSong,nowPlayTap: false);
    }

    Widget _buildIamge() {
      return new ClipPath(
          clipper: new DialogonalClipper(),
          child: new Image.asset(
            'assets/bubbles.jpeg',
            fit: BoxFit.cover,
            height: 200.0,
            width: screenSize.width,
            colorBlendMode: BlendMode.srcOver,
            color: new Color.fromARGB(120, 20, 10, 40),
          ),
        );

    }

    Widget _buildTopHeader() {
      return new Container(
        height: 80.0,
        child: new AppBar(
          backgroundColor: Colors.transparent,
          title: new Text("Flutter Music Player"),
          actions: <Widget>[
            new Container(
              height:60.0,
              padding: const EdgeInsets.all(20.0),
              child: new Center(
                child: new InkWell(
                    child: new Text("Now Playing",),
                    onTap: () => goToNowPlaying(
                      rootIW.songData.songs[
                      (rootIW.songData.currentIndex == null ||
                          rootIW.songData.currentIndex < 0)
                          ? 0
                          : rootIW.songData.currentIndex],
                      nowPlayTap: true,
                    )),
              ),
            )
          ],
        ),
      );
    }

    Widget _buildFab() {
      return new Positioned(
        top: 200 - 160.0,
        right: -30.0,
          child: new AnimatedFab(
            onClick: null,
            onTapOne: (){
              shuffleSongs();
            },
          ),
      );
    }

    Widget _buildPageheader() {
      return new Padding(
        padding: new EdgeInsets.only(top: 105),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.only(left: 45.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    'All tracks',
                    style: new TextStyle(fontSize: 34.0),
                  ),
                  new Text(
                    "${rootIW.songData.length} Tracks",
                    style: new TextStyle(color: Colors.grey, fontSize: 12.0),
                  ),
                ],
              ),
            )
          ],
        ),
      );

    }
    return new Scaffold(
      /*appBar: new AppBar(
        title: new Text("Flutter Music Player"),
        actions: <Widget>[
          new Container(
            padding: const EdgeInsets.all(20.0),
            child: new Center(
              child: new InkWell(
                  child: new Text("Now Playing"),
                  onTap: () => goToNowPlaying(
                        rootIW.songData.songs[
                            (rootIW.songData.currentIndex == null ||
                                    rootIW.songData.currentIndex < 0)
                                ? 0
                                : rootIW.songData.currentIndex],
                        nowPlayTap: true,
                      )),
            ),
          )
        ],
      ),*/
      // drawer: new MPDrawer(),
      body: new ListView(
        children: <Widget>[
          new Stack(
            children: <Widget>[
              _buildIamge(),
              _buildTopHeader(),
              _buildFab(),
              _buildPageheader()
            ],
          ),
          new Container(
            alignment: Alignment(0.0, 0.5),
            height: screenSize.height-200,
            child: rootIW.isLoading
                ? new Center(child: new CircularProgressIndicator())
                : new ScrollConfiguration(behavior: MyBehavior(), child: new Scrollbar(child: new MPListView())),
          )
        ],
      ),

      bottomNavigationBar:
          rootIW.songData != null && rootIW.songData.currentIndex != -1
              ? new Material(
                  child: new Container(
                      decoration: BoxDecoration(),
                      height: 60.0,
                      child: _buildBottomNavigationBar(
                        OnTap: () => goToNowPlaying(
                              rootIW.songData.songs[
                                  (rootIW.songData.currentIndex == null ||
                                          rootIW.songData.currentIndex < 0)
                                      ? 0
                                      : rootIW.songData.currentIndex],
                              nowPlayTap: true,
                            ),
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
                  elevation: 50.0,
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

class DialogonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0.0, size.height - 60.0 );
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}


class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

