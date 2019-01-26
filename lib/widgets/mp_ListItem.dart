import 'package:flutter/material.dart';
import 'dart:ui';
import '../data/PlayerStateEnum.dart';


class ListData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ListDataState();

  final EdgeInsets margin;
  final double width;
  final String title;
  final String subtitle;
  final DecorationImage image;
  final VoidCallback OnTap;
  PlayerState isPlaying;
  final MaterialColor color;
  final VoidCallback ActiveCallback;

  ListData(
      {this.margin,
      this.subtitle,
      this.title,
      this.width,
      this.color,
      this.image,
      this.OnTap,
      this.isPlaying,
      this.ActiveCallback}
      );
}

class ListDataState extends State<ListData> {
  EdgeInsets margin;
  double width;
  String title;
  String subtitle;
  DecorationImage image;
  VoidCallback OnTap;
  PlayerState isPlaying;
  MaterialColor color;

  void _OnItemTap() {
    setState(() {
      if (this.isPlaying == PlayerState.stopped || this.isPlaying == PlayerState.paused) {
        this.isPlaying = PlayerState.playing;
      }
      widget.OnTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    this.margin = widget.margin;
    this.width = widget.width;
    this.title = widget.title;
    this.subtitle = widget.subtitle;
    this.image = widget.image;
    this.OnTap = widget.OnTap;
    this.isPlaying = widget.isPlaying;
    this.color = widget.color;
    return (new InkWell(

        onTap: () {
          _OnItemTap();
        },
        child: new Container(
          alignment: Alignment.center,
          margin: widget.margin,
          width: widget.width,
          height: 80.0,
          decoration: new BoxDecoration(
            color: Colors.transparent,
          ),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new InkWell(
                radius: 80.0,
                child: widget.image != null
                    ? new Container(
                    margin: new EdgeInsets.only(
                        left: 20.0, top: 10.0, bottom: 10.0, right: 20.0),
                    width: 60.0,
                    height: 60.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle, image: widget.image),
                    child: widget.isPlaying != null
                        ? new BackdropFilter(
                      filter: new ImageFilter.blur(
                          sigmaX: 4.0, sigmaY: 4.0),
                      child: new Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: new BoxDecoration(
                            color:
                            Colors.grey.shade500.withOpacity(0.01),
                            shape: BoxShape.circle),
                        child: new Icon(
                          isPlaying==PlayerState.playing? Icons.pause:isPlaying==PlayerState.stopped? Icons.play_arrow:Icons.play_arrow,
                          color: Colors.grey.shade500,
                          size: 35.0,
                        ),
                        alignment: Alignment(0.0, 0.0),
                      ),
                    )
                        : new Container())
                    : new Container(
                  margin: new EdgeInsets.only(
                      left: 20.0, top: 10.0, bottom: 10.0, right: 20.0),
                  width: 60.0,
                  height: 60.0,
                  child: new CircleAvatar(
                    child: widget.isPlaying != null
                        ? new Icon(
                      isPlaying==PlayerState.playing? Icons.pause:isPlaying==PlayerState.stopped? Icons.play_arrow:Icons.play_arrow,
                      color: Colors.grey.shade500,
                      size: 35.0,
                    )
                        : new Icon(
                      Icons.music_note,
                      color: Colors.white,
                    ),
                    backgroundColor: widget.color,
                  ),
                ),
                onTap: (){
                  widget.ActiveCallback();
                },
              ),
              new Expanded(
                  child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(widget.title,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 2,
                      style: new TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      )),
                  new Padding(
                    padding: new EdgeInsets.only(top: 5.0),
                    child: new Text(
                      widget.subtitle,
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
