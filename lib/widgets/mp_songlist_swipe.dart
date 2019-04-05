import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class mp_songlist_swipe extends StatelessWidget {
  List Itmes;
  int StartingIndex;

  dynamic OnNext;
  dynamic Controller;

  mp_songlist_swipe(List Items, int StartingIndex, OnNext, Controller) {
    this.Itmes = Items;
    this.StartingIndex = StartingIndex;
    this.OnNext = OnNext;
    this.Controller = Controller;
  }

  @override
  Widget build(BuildContext context) {
    return _buildCarousel(context, 1);
  }

  Widget _buildCarousel(BuildContext context, int carouselIndex) {
    PageController controller = PageController(
      viewportFraction: 1.0,
      initialPage: StartingIndex,
    );
    Controller(controller);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return new Material(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              // you may want to use an aspect ratio here for tablet support
              height: width,
              width: width,
              child: PageView.builder(
                // store this controller in a State to save the carousel scroll position
                controller: controller,
                itemBuilder: (BuildContext context, int itemIndex) {
                  return _buildCarouselItem(context, carouselIndex, itemIndex);
                },
                physics: PageScrollPhysics(),
                itemCount: Itmes.length,
                onPageChanged: (int) {
                  OnNext(int);
                },
              ),
            )
          ],
        ),
        height: width,
        decoration: BoxDecoration(color: Colors.transparent),
      ),
      elevation: 15.0,
      type: MaterialType.transparency,
    );
  }

  Widget _buildCarouselItem(
      BuildContext context, int carouselIndex, int itemIndex) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    Song item = Itmes[itemIndex];
    String thumb = item.albumArt;
    var artFile = item.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(item.albumArt));
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0),
        child: new Material(
          child: Container(
            decoration: BoxDecoration(
              image: new DecorationImage(
                image: thumb != null && thumb != "" && artFile.existsSync()
                    ? new AssetImage(
                        thumb,
                      )
                    : new AssetImage(
                        "assets/back.png",
                      ),
                fit: BoxFit.cover,
              ),
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            width: width,
          ),
          type: MaterialType.card,
        ));
  }
}
