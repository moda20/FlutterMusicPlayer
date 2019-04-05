
import 'package:flutter/material.dart';
import '../data/SongDatabase.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
class AlbumList extends StatefulWidget {
  final List albums;

 AlbumList(this.albums);

  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
  @override
  Widget build(BuildContext context) {
    return _buildArtistPage(context,widget.albums);
  }



  Widget _buildArtistPage(BuildContext context,List<LocalAlbum> albums){
    Orientation orientation = MediaQuery.of(context).orientation;
    List<Card> theList = new List();

    for(var i = 0; i< albums.length; i ++){
      theList.add(buildTrendingWidget(context,(){},0,albums[i].AlbumArt,albums[i].name,albums[i].ArtistName,albums[i].AlbumSongs));
    }

    return Scrollbar(
      child: new GridView.count(
        crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
        children: theList,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        childAspectRatio: 8.0 / 9.5,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 18.0,
      ),
    );
  }


  Widget buildTrendingWidget(BuildContext context,Function callback,int index, String thumb, String title, String artist, Map Songs)
  {
    Orientation orientation = MediaQuery.of(context).orientation;
    var artFile = thumb!=null && thumb !=""?
    File.fromUri(Uri.parse(thumb)):null;
    return Card(
      color: Colors.transparent,
      elevation: 8.0,
      child: new InkResponse(
        onTap: () {

        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: Stack(
            children: <Widget>[
              Hero(
                tag: artist,
                child: thumb != null && thumb != "" && artFile.existsSync()
                    ? Container(
                  color: Colors.blueGrey.shade300,
                  child: new Image.file(
                    artFile,
                    height: double.infinity,
                    fit: BoxFit.fitHeight,
                  ),
                )
                    : new Image.asset(
                  "assets/back.png",
                  height: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Positioned(
                bottom: 0.0,
                child: Container(
                  width: orientation == Orientation.portrait
                      ? (MediaQuery.of(context).size.width - 26.0) / 2
                      : (MediaQuery.of(context).size.width - 26.0) / 4,
                  color: Colors.white.withOpacity(0.88),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                      Padding(
                        padding: const EdgeInsets.only(left: 7.0, right: 7.0),
                        child: Text(
                          artist,
                          style: new TextStyle(
                              fontSize: 15.5,
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Padding(
                          padding: EdgeInsets.only(left: 7.0, right: 7.0),
                          child: Text(
                            title,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black.withOpacity(0.75),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 4.0))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
