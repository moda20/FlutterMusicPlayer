
import './song_data.dart';
import 'package:flute_music_player/flute_music_player.dart' show Song;

class LocalSong{
  String name;
  String uri;
  String albumName;
  String albumArt;
  String ArtistName;
  String LocalId;
  String OriginalId;
  int duration;
  int AlbumId;

  LocalSong(this.name,this.uri,this.albumName,this.ArtistName,this.LocalId,this.OriginalId,
      this.duration,this.AlbumId);

  LocalSong.fromMap(Map m){
     name = m["name"];
     uri = m["uri"];
     albumName = m["albumName"];
     albumArt = m["albumArt"];
     ArtistName = m["ArtistName"];
     LocalId = m["LocalId"].toString();
     OriginalId = m["OriginalId"].toString();
     duration = m["duration"];
     AlbumId = m["AlbumId"];
  }

  @override
  String toString() {
    return 'LocalSong{name: $name, uri: $uri, albumName: $albumName, albumArt: $albumArt, ArtistName: $ArtistName, LocalId: $LocalId, OriginalId: $OriginalId, duration: $duration, AlbumId: $AlbumId}';
  }

}

class LocalAlbum{
  String name;
  String AlbumArt;
  String ArtistName;
  int totalDuration;
  String LocalId;
  String OriginalId;
  Map<String,LocalSong> AlbumSongs; // this mapping is between localId of songs not the original Id

  LocalAlbum(this.name,this.AlbumArt, this.ArtistName, this.totalDuration, this.LocalId, this.OriginalId){
    for(var i =0;i<AlbumSongs.length; i++){
      totalDuration+=AlbumSongs[i].duration;
    }
  }

  AddNewSong(Map LSong){
    LocalSong newSong = LocalSong.fromMap(LSong);
    this.AlbumSongs[newSong.LocalId] = newSong;
    this.totalDuration+=newSong.duration;
  }


  LocalAlbum.fromMap(Map m){
     name = m["name"];
     AlbumArt = m["AlbumArt"];
     ArtistName =m["ArtistName"];
     totalDuration =m["totalDuration"];
     LocalId =m["LocalId"].toString();
     OriginalId=m["OriginalId"].toString();
     Map<String,LocalSong> Songs = new Map<String,LocalSong>();
     if(m["AlbumSongs"] !=null){
       for(var i in m["AlbumSongs"].keys){
         LocalSong song = new LocalSong.fromMap(m["AlbumSongs"][i]);
          Songs[song.LocalId]=song;
       }
     }
    AlbumSongs =Songs;
  }

  @override
  String toString() {
    return 'LocalAlbum{name: $name, AlbumArt: $AlbumArt, ArtistName: $ArtistName, totalDuration: $totalDuration, LocalId: $LocalId, OriginalId: $OriginalId, AlbumSongs: $AlbumSongs}';
  }

}


class SongDatabase {
  SongData OriginalSongData;
  Map<String,LocalSong> SongList; // this mapping is between localId of songs not the original Id
  Map<String,LocalAlbum> AlbumList;
  DateTime updatedAt=DateTime.now();
  bool isIdenticalToLocal;
  int CurrentSongID=0;
  int CurrentAlbumID=0;
  CreateNewId(){
    CurrentSongID++;
    return CurrentSongID;
  }
  CreateNewAlbumId(){
    CurrentAlbumID++;
    return CurrentAlbumID;
  }
  SongDatabase(this.OriginalSongData,this.SongList,this.updatedAt,this.isIdenticalToLocal,this.AlbumList){
    this.updatedAt = DateTime.now();
  }

  SongDatabase.fromMap(Map m,{this.OriginalSongData = null}){
    print(this.OriginalSongData==null?"Didn't Pass an original SongData File, will rely on localsongs data":"");
    Map<String,LocalSong> Songs;
    if(m["SongList"] !=null){
      for(var i =0; i<m["SongList"].length; i++){
        LocalSong song = new LocalSong.fromMap(m["SongList"][i]);
        Songs[song.LocalId]=song;
      }
    }
    SongList = Songs;
    updatedAt = m["updatedAt"];
    isIdenticalToLocal = m["isIdenticalToLocal"];
    Map<String,LocalAlbum> Albums;
    if(m["AlbumList"] !=null){
      for(var i =0; i<m["AlbumList"].length; i++){
        LocalAlbum Album = new LocalAlbum.fromMap(m["AlbumList"][i]);
        Albums[Album.LocalId]=Album;
      }
    }
    AlbumList =Albums;
  }


  initiateOriginalToLocalDatabaseTransfer(){
    if(this.OriginalSongData==null){
      print("Didn't Pass an original SongData");
      return null;
    }
    Map<String,Map<String,dynamic>> AlbumMaps = new Map<String,Map<String,dynamic>>();
    // For every Original Song
    for(var i=0;i<this.OriginalSongData.length; i++){
      Song ogSong = this.OriginalSongData.songs[i];
      //Create a LocalSongMap version of the original Song
      Map ogSongMap ={
      "name" : ogSong.title,
      "uri" : ogSong.uri,
      "albumName" : ogSong.album,
      "albumArt" : ogSong.albumArt,
      "ArtistName" : ogSong.artist,
      "LocalId" : CreateNewId(),
      "OriginalId" : ogSong.id,
      "duration" : ogSong.duration,
      "AlbumId" : ogSong.albumId,
      };
      // Check if this song exists, based on Original Id (We assume if the song exists then it was added before)
      var SongExists = SongExistAlready(ogSong.id);
      if(SongExists==null){
        //If the song doesn't exist
        //Add the song to the Song list
        LocalSong LNewSong = LocalSong.fromMap(ogSongMap);
        SongList[LNewSong.LocalId]=LNewSong;
        //Check if its album exists
        var AlbumExists = AlbumExistAlready(ogSong.albumId);
        if(AlbumExists==null){
          //If the album doesn't exist
          //Create a New Map version of a Local Album
          Map<String, dynamic> AlbumMap = {
            "name" : ogSong.album,
            "AlbumArt" : ogSong.albumArt,
            "ArtistName" :ogSong.artist,
            "totalDuration" :ogSong.duration,
            "LocalId" : CreateNewAlbumId(),
            "OriginalId" : ogSong.albumId,
            "AlbumSongs" : new Map(),
          };
          //Check if we already are going to add this new Album
          if(AlbumMaps.containsKey(AlbumMap["LocalId"])){
            // If we have already done so, we add this song to that album
            AlbumMaps[AlbumMap["LocalId"]]["AlbumSongs"][SongExists]=ogSongMap;
          }else{
            //If we didn't add this album before
            //Add The current song map to our New Map version of a Local Album
            AlbumMap["AlbumSongs"][SongExists]=ogSongMap;
            AlbumMaps[AlbumMap["LocalId"].toString()]=AlbumMap;
          }

        }
        // If the album does exist
        if(AlbumExists!=null){
          //Add the current Song ot the Existing album via the dedicated method
          AlbumList[AlbumExists].AddNewSong(ogSongMap);
        }
      }

    }
    // After creating the totally New Albums, We add them OneByOne to the current AlbumList
    print("New albums length ${AlbumMaps.length}");
    for(var Amap in AlbumMaps.keys){
      LocalAlbum NewLocalAlbum = LocalAlbum.fromMap(AlbumMaps[Amap]);
      AlbumList[NewLocalAlbum.LocalId]=NewLocalAlbum;
    }
  }

  SongExistAlready(OriginalId){
    Iterable found = SongList.values.where((LocalSong){
      return LocalSong.OriginalId==OriginalId;
    });
    if(found.length!=0){
      var localId = found.elementAt(0).LocalId;
      return localId;

    }
    return null;
  }

  AlbumExistAlready(OriginalId){
    Iterable found = AlbumList.values.where((LocalAlbum){
      return LocalAlbum.OriginalId==OriginalId;
    });
    if(found.length!=0){
      var localId = found.elementAt(0).LocalId;
      return localId;

    }
    return null;
  }

  @override
  String toString() {
    return 'SongDatabase{OriginalSongData: $OriginalSongData, SongList: $SongList, AlbumList: $AlbumList, updatedAt: $updatedAt, isIdenticalToLocal: $isIdenticalToLocal, CurrentSongID: $CurrentSongID, CurrentAlbumID: $CurrentAlbumID}';
  }


  SaveDatatabse(){

  }

  ReadDatabase(){

  }
}