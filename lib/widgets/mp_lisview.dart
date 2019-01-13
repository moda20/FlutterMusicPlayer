import 'dart:io';
import 'package:flute_example/data/song_data.dart';
import 'package:flute_example/pages/now_playing.dart';
import 'package:flute_example/widgets/mp_circle_avatar.dart';
import 'package:flute_example/widgets/mp_inherited.dart';
import 'package:flutter/material.dart';
import './mp_ListItem.dart';
class MPListView extends StatelessWidget {
  final List<MaterialColor> _colors = Colors.primaries;
  @override
  Widget build(BuildContext context) {
    final rootIW = MPInheritedWidget.of(context);
    SongData songData = rootIW.songData;
    Size screenSize = MediaQuery.of(context).size;
    return new ListView.builder(
      itemCount: songData.songs.length,
      itemBuilder: (context, int index) {

        var s = songData.songs[index];
        final MaterialColor color = _colors[index % _colors.length];
        var artFile =
            s.albumArt == null ? null : new File.fromUri(Uri.parse(s.albumArt));

        /*return new ListTile(
          dense: false,
          leading: new Hero(
            child: avatar(artFile, s.title, color),
            tag: s.title,
          ),
          title: new Text(s.title),
          subtitle: new Text(
            "By ${s.artist}",
            style: Theme.of(context).textTheme.caption,
          ),
          onTap: () {
            songData.setCurrentIndex(index);
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new NowPlaying(songData, s)));
          },
        );*/

        return new ListData(
            OnTap:() {
              songData.setCurrentIndex(index);
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new NowPlaying(songData, s)));
            },
            margin: EdgeInsets.all(4.0),
            width: screenSize.width,
            title: s.title,
            isPlaying : songData.currentIndex!=-1 ? s.id == songData.songs[songData.currentIndex].id : false,
            subtitle: "By ${s.artist}",
            image: artFile!=null ? DecorationImage(image:  new FileImage(artFile) ,
                fit: BoxFit.cover): null,
           color: color,
        );


      },
    );
  }
}
