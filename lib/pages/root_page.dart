import 'package:flute_example/pages/now_playing.dart';
import 'package:flute_example/widgets/mp_inherited.dart';
import 'package:flute_example/widgets/mp_lisview.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import '../widgets/mp_ListItem.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import '../data/PlayerStateEnum.dart';
import '../widgets/mp_animatedFab.dart';
import '../widgets/mp_bottom_nowPlaying.dart';
class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rootIW = MPInheritedWidget.of(context);
    Size screenSize = MediaQuery.of(context).size;

    final StreamController changeNotifier = new StreamController.broadcast();
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
      changeNotifier.add(null);
    }

    //Shuffle Songs and goto now playing page
    void shuffleSongs() {
      Map RandomSong = rootIW.songData.randomSongMap;
      rootIW.songData.setCurrentIndex(RandomSong["index"]);
      goToNowPlaying(RandomSong["song"],nowPlayTap: false);
    }
    @override
    void dispose() {
      changeNotifier.close();
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
                    "${rootIW.songData != null? rootIW.songData.length:0} Tracks",
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
          BottomNowPlaying(onTap: (){
            goToNowPlaying(
              rootIW.songData.songs[
              (rootIW.songData.currentIndex == null ||
                  rootIW.songData.currentIndex < 0)
                  ? 0
                  : rootIW.songData.currentIndex],
              nowPlayTap: true,
            );
          },
          changeState: changeNotifier.stream)
    );
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

