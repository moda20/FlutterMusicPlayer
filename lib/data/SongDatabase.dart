
import './song_data.dart';
import 'package:flute_music_player/flute_music_player.dart' show Song;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
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

 /* String toJson(){
    return 'LocalSong{"name": $name, "uri": $uri, "albumName": $albumName, "albumArt": $albumArt, "ArtistName": $ArtistName, "LocalId": $LocalId, "OriginalId": $OriginalId, "duration": $duration, "AlbumId": $AlbumId}';
  }*/

  Map<String, dynamic> toJson() => {
    "name": name, "uri": uri, "albumName": albumName, "albumArt": albumArt, "ArtistName": ArtistName, "LocalId": LocalId, "OriginalId": OriginalId, "duration": duration, "AlbumId": AlbumId
  };

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

  Map<String, dynamic> toJson(){
    String jsonSongs ="";
    Map newAlbum =AlbumSongs;
    newAlbum.forEach((key,song){
      song.toJson();
    });
    return {
      "name": name, "AlbumArt": AlbumArt, "ArtistName": ArtistName, "totalDuration": totalDuration, "LocalId": LocalId, "OriginalId": OriginalId, "AlbumSongs": newAlbum
    };
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
  SongDatabase({this.OriginalSongData,this.SongList,this.updatedAt,this.isIdenticalToLocal,this.AlbumList}){
    this.updatedAt = DateTime.now();
    this.SongList==null?this.SongList = new Map():this.SongList;
    this.AlbumList==null?this.AlbumList = new Map():this.SongList;
  }

  SongDatabase.fromMap(Map m,{this.OriginalSongData = null}){
    var it = 1;
    print(this.OriginalSongData==null?"Didn't Pass an original SongData File, will rely on localsongs data":"");
    Map<String,LocalSong> Songs = new Map();
    if(m["SongList"] !=null){
      for(var i =1; i<m["SongList"].length; i++){
        LocalSong song = new LocalSong.fromMap(m["SongList"][i.toString()]);
        Songs[song.LocalId]=song;
        it = i;
      }
    }
    SongList = Songs;
    updatedAt = DateTime.parse(m["updatedAt"]);
    isIdenticalToLocal = m["isIdenticalToLocal"];
    Map<String,LocalAlbum> Albums = new Map();
    if(m["AlbumList"] !=null){
      for(var i =1; i<m["AlbumList"].length; i++){
        LocalAlbum Album = new LocalAlbum.fromMap(m["AlbumList"][i.toString()]);
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

          //Check if we already are going to add this new Album
          //In this check we will be basing on the original Id because that one is a
          // not generated key
          if(AlbumMaps.containsKey(ogSong.albumId.toString())){

            // If we have already done so, we add this song to that album
            AlbumMaps[ogSong.albumId.toString()]["AlbumSongs"][LNewSong.LocalId]=ogSongMap;
          }else{
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
            //If we didn't add this album before
            //Add The current song map to our New Map version of a Local Album
            AlbumMap["AlbumSongs"][LNewSong.LocalId]=ogSongMap;
            AlbumMaps[AlbumMap["OriginalId"].toString()]=AlbumMap;
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

    List<LocalAlbum> albums = AlbumList.values.toList();
    for(var i =0; i< albums.length; i++){
      if(albums[i].OriginalId == int.parse(OriginalId)){
        return albums[i].LocalId;
      }
    }

    return null;
  }


 List  toAlbumList(){
    List<LocalAlbum> theList = new List();
    var keys = this.AlbumList.keys;
    for(var i=0;i<this.AlbumList.length; i++){
      theList.add(AlbumList[keys.elementAt(i)]);
    }
    return theList;
  }

  @override
  String toString() {
    return 'SongDatabase{OriginalSongData: $OriginalSongData, SongList: $SongList, AlbumList: $AlbumList, updatedAt: $updatedAt, isIdenticalToLocal: $isIdenticalToLocal, CurrentSongID: $CurrentSongID, CurrentAlbumID: $CurrentAlbumID}';
  }


  Map<String, dynamic> toJson() {
    Map LabumNewList = AlbumList;
    LabumNewList.forEach((key,album){
      album.toJson();
    });
   return {
     "SongList": SongList, "AlbumList": LabumNewList, "updatedAt": updatedAt.toString(), "isIdenticalToLocal": isIdenticalToLocal, "CurrentSongID": CurrentSongID, "CurrentAlbumID": CurrentAlbumID
   };
  }


  SaveDatatabse(){
    writeCounter(json.encode(this.toJson())).then((data){
      print('file saved ${data}');
    });
  }

  Future<SongDatabase> ReadDatabase() async{

        String string = await  readDb();

        SongDatabase newDB = new SongDatabase.fromMap(json.decode(string));
        return newDB;

  }


  // Rescan Library, would require an app restart


/*  Future<void> rescanLibrary(){


      try {
        songs = await OriginalSongData.musicFinder.allSongs();
        print("Parsed Songs from Storage");
        songData = new SongData(songDatabase, songs);
        songDatabase = new SongDatabase(
          OriginalSongData: songData,
        );
        songDatabase.initiateOriginalToLocalDatabaseTransfer();
        songDatabase.SaveDatatabse();
      } catch (e) {
        print(e);
        print("Failed to get songs: '${e.message}'.");
      }

  }*/


  // helpers to get reading and writing to files

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/songdb.json');
  }

  Future<File> writeCounter(String jsonString) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(jsonString);
  }

  Future<String> readDb() async {
    final file = await _localFile;

    // read the file
    return await file.readAsString();
  }



}