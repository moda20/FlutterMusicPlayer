import 'package:flute_music_player/flute_music_player.dart';
import 'dart:math';
import 'dart:async';
import './PlayerStateEnum.dart';
import '../data/SongDatabase.dart';

class SongData {
  List<Song> _songs;
  SongDatabase songDatabase;
  int _currentSongIndex = -1;
  PlayerState playerState= PlayerState.stopped;
  MusicFinder musicFinder;
  final StreamController changeNotifier = new StreamController.broadcast();
  final StreamController AppNotifier = new StreamController.broadcast();
  SongData(this.songDatabase,this._songs) {

    musicFinder = new MusicFinder();
    if(this._songs ==null){
      this._songs=new List();
      var keys = this.songDatabase.SongList.keys;
      for(var i =0; i<this.songDatabase.SongList.length; i++){
        LocalSong elem = this.songDatabase.SongList[keys.elementAt(i)];

        this._songs.add(new Song(
            int.tryParse(elem.OriginalId),
            elem.ArtistName,
            elem.name,
            elem.albumName,
            elem.AlbumId,
            elem.duration,
            elem.uri,
            elem.albumArt
        ));

      }
    }
    print(this._songs);

  }

  List<Song> get songs => _songs;
  int get length => _songs.length;
  int get songNumber => _currentSongIndex + 1;

  setCurrentIndex(int index) {
    _currentSongIndex = index;
  }

  int get currentIndex => _currentSongIndex;

  Song get nextSong {
    if (_currentSongIndex < length) {
      _currentSongIndex++;
    }
    if (_currentSongIndex >= length) return null;
    return _songs[_currentSongIndex];
  }

  int CurrentIndexOfSong(Song s){
    return songs.indexWhere((x) => x.id==s.id);
  }

  Song get randomSong {
    Random r = new Random();
    return _songs[r.nextInt(_songs.length)];
  }

  Map get randomSongMap {
    Random r = new Random();
    var index = r.nextInt(_songs.length);
    return {"song":_songs[index],"index":index };
  }

  Song get prevSong {
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
    }
    if (_currentSongIndex < 0) return null;
    return _songs[_currentSongIndex];
  }

  MusicFinder get audioPlayer => musicFinder;

  void sort(){
    int oldIndex = currentIndex;
    Song oldSong = currentIndex!=-1?songs[currentIndex]:null;
    songs.sort((a, b) => a.title.compareTo(b.title));
    currentIndex!=-1?setCurrentIndex(songs.indexWhere((x) => x.id==oldSong.id)):null;
  }

  void sortByDuration(){
    int oldIndex = currentIndex;
    Song oldSong = currentIndex!=-1?songs[currentIndex]:null;
    songs.sort((a, b) => a.duration.compareTo(b.duration));
    currentIndex!=-1?setCurrentIndex(songs.indexWhere((x) => x.id==oldSong.id)):null;
  }

  void sortByArtist(){
    int oldIndex = currentIndex;
    Song oldSong = currentIndex!=-1?songs[currentIndex]:null;
    songs.sort((a, b) => a.artist.compareTo(b.artist));
    currentIndex!=-1?setCurrentIndex(songs.indexWhere((x) => x.id==oldSong.id)):null;
  }
}
