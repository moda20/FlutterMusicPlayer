import 'package:flute_example/data/song_data.dart';
import 'package:flutter/material.dart';
import '../data/SongDatabase.dart';

class MPInheritedWidget extends InheritedWidget {
  final SongData songData;
  final bool isLoading;
  final SongDatabase songDatabase;

  const MPInheritedWidget(this.songData, this.isLoading, child,this.songDatabase)
      : super(child: child);

  static MPInheritedWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MPInheritedWidget);
  }

  @override
  bool updateShouldNotify(MPInheritedWidget oldWidget) =>
      // TODO: implement updateShouldNotify
  songDatabase != oldWidget.songDatabase || songData != oldWidget.songData || isLoading != oldWidget.isLoading;
}
