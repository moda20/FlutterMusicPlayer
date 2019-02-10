import 'package:flute_example/pages/now_playing.dart';
import 'package:flute_example/widgets/mp_inherited.dart';
import 'package:flute_example/widgets/mp_lisview.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import '../widgets/mp_ListItem.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import '../data/PlayerStateEnum.dart';
import '../widgets/mp_animatedFab.dart';
import '../widgets/mp_bottom_nowPlaying.dart';
import '../Services/MusicPlayerService.dart';
import '../data/SongDatabase.dart';
import '../Services/SoptifyDataService.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rootIW = MPInheritedWidget.of(context);
    Size screenSize = MediaQuery.of(context).size;
    MusicService PLayer =
        new MusicService(rootIW.songData.audioPlayer, rootIW.songData);
    SongDatabase DB = new SongDatabase(rootIW.songData,new Map(),DateTime.now(),false,new Map());
    print(DB);
    DB.initiateOriginalToLocalDatabaseTransfer();
    print(DB);
    SpotifyService SPS = new SpotifyService();
    SPS.getSpotifyArtist(SPS.clientID, SPS.clienSecret, null).then(
        (data){
          print(data.name);
        }
    );
    String url = "https://accounts.spotify.com/authorize?client_id=${SPS.clientID}&response_type=code&redirect_uri=${SPS.redirectUrl}&scope=user-read-private%20user-read-email&state=34fFs29kd09";
    SPS.promptUsertoLogin(url, context);
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
      Map RandomSong = PLayer.songData.randomSongMap;
      PLayer.songData.setCurrentIndex(RandomSong["index"]);
      if (PLayer.Status == PlayerState.playing && PLayer.isPlayingId != null) {
        if (RandomSong["song"].id != PLayer.isPlayingId) {
          print("Not the same song");
          PLayer.stop().then((stopped) {
            PLayer.playById(RandomSong["song"].id).then((onValue) {
              PLayer.songData.changeNotifier.add(null);
              PLayer.songData.changeNotifier.add("sorted");
              goToNowPlaying(RandomSong["song"], nowPlayTap: false);
            });
          });
        } else {
          PLayer.pause().then((onValue) {
            PLayer.songData.changeNotifier.add(null);
            PLayer.songData.changeNotifier.add("sorted");
          });
        }
      } else {
        if (RandomSong["song"].id != PLayer.isPlayingId) {
          print("Not the same song");
          PLayer.stop().then((stopped) {
            PLayer.playById(RandomSong["song"].id).then((onValue) {
              PLayer.songData.changeNotifier.add(null);
              PLayer.songData.changeNotifier.add("sorted");
              goToNowPlaying(RandomSong["song"], nowPlayTap: false);
            });
          });
        } else {
          PLayer.playById(RandomSong["song"].id).then((onValue) {
            PLayer.songData.changeNotifier.add(null);
            PLayer.songData.changeNotifier.add("sorted");
            goToNowPlaying(RandomSong["song"], nowPlayTap: false);
          });
        }
      }
      print("rootIndex ${PLayer.songData.currentIndex}");
      print("Random index ${RandomSong["index"]}");
      print(RandomSong["song"].title);
    }

    //sort songs byName
    void sortSongs() {
      PLayer.songData.sort();
      PLayer.songData.changeNotifier.add("sorted");
    }

    void sortSongsByDuration() {
      PLayer.songData.sortByDuration();
      PLayer.songData.changeNotifier.add("sorted");
    }

    void sortSongsByArtist() {
      PLayer.songData.sortByArtist();
      PLayer.songData.changeNotifier.add("sorted");
    }

    @override
    void dispose() {
      /*changeNotifier.close();*/
    }

    Widget _buildIamge() {
      return new Container(
        child: new ClipPath(
          clipper: new DialogonalClipper(),
          child: new Image.asset(
            'assets/bubbles.jpeg',
            fit: BoxFit.cover,
            height: 200.0,
            width: screenSize.width,
            colorBlendMode: BlendMode.srcOver,
            color: new Color.fromARGB(120, 20, 10, 40),
          ),
        ),
        decoration: BoxDecoration(color: Colors.white.withAlpha(9)),
      );
    }

    Widget _buildTopHeader() {
      return new Container(
        height: 80.0,
        child: new AppBar(
          backgroundColor: Colors.transparent,
          title: new Text("Flutter Music Player"),
          actions: <Widget>[
            /*new Container(
              height: 60.0,
              padding: const EdgeInsets.all(20.0),
              child: new Center(
                child: new InkWell(
                    child: new Text(
                      "Now Playing",
                    ),
                    onTap: () => goToNowPlaying(
                      PLayer.isPlayingSong,
                          nowPlayTap: true,
                        )),
              ),
            )*/
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
          onTapOne: () {
            shuffleSongs();
          },
          onTapTwo: () {
            sortSongs();
          },
          onTapThree: () {
            sortSongsByDuration();
          },
          onTapFour: () {
            sortSongsByArtist();
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
                    "${PLayer.songData != null ? PLayer.songData.length : 0} Tracks",
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
        body: new Container(
          height: screenSize.height * 2,
          child: new NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 180,
                  title: new Text("Flutter Music Player"),
                  actions: <Widget>[
                    /*new Center(

                      child: new InkWell(
                          child: new Text(
                            "Now Playing",
                          ),
                          onTap: () => goToNowPlaying(
                            PLayer.isPlayingSong!=null?PLayer.isPlayingSong:PLayer.songData.songs[0],
                                nowPlayTap: true,
                              )),
                      widthFactor: 1.3,
                    ),*/
                  ],
                  pinned: true,
                  snap: true,
                  floating: true,
                  flexibleSpace: new Stack(
                    children: <Widget>[
                      _buildIamge(),
                      /*_buildTopHeader(),*/
                      _buildFab(),
                      _buildPageheader()
                    ],
                  ),
                )
              ];
            },
            body: new Container(
              alignment: Alignment(0.0, 0.5),
              height: screenSize.height - 200,
              child: rootIW.isLoading
                  ? new Center(child: new CircularProgressIndicator())
                  : new ScrollConfiguration(
                      behavior: MyBehavior(),
                      child: new Scrollbar(
                          child: new MPListView(
                        changeState: changeNotifier.stream,
                        changeNotifier: changeNotifier,
                      ))),
            ),
          ),
        ),
        bottomNavigationBar: BottomNowPlaying(
            onTap: () {
              if (PLayer.Status == PlayerState.playing &&
                  PLayer.isPlayingId != null) {
                changeNotifier.add(null);
              } else {
                PLayer.playById(PLayer.isPlayingId).then((onValue) {
                  changeNotifier.add(null);
                });
              }
              goToNowPlaying(
                PLayer.isPlayingSong,
                nowPlayTap: false,
              );
            },
            changeState: changeNotifier.stream));
  }
}

class DialogonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0.0, size.height);
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
