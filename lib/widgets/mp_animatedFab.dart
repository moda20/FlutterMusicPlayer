import 'package:flutter/material.dart';
import 'dart:math' as math;
class AnimatedFab extends StatefulWidget {
  final VoidCallback onClick;
  final VoidCallback onTapOne;
  final VoidCallback onTapTwo;
  const AnimatedFab({Key key, this.onClick, this.onTapOne, this.onTapTwo}) : super(key: key);

  @override
  _AnimatedFabState createState() => new _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab> with SingleTickerProviderStateMixin  {

  AnimationController _animationController;
  Animation<Color> _colorAnimation;
  final double expandedSize = 180.0;
  final double hiddenSize = 20.0;
  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _colorAnimation = new ColorTween(begin: Colors.pink, end: Colors.pink[800])
        .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      width: expandedSize,
      height: expandedSize,
      child: new AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          return new Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _buildExpandedBackground(),
              _buildFabCore(),
              _buildOption(Icons.shuffle, 0.0, (){
                widget.onTapOne();
                close();
              }),
              _buildOption(Icons.flash_on, -math.pi / 3,(){
                widget.onTapTwo();
                close();
              }),
              _buildOption(Icons.access_time, -2 * math.pi / 3,null),
              _buildOption(Icons.error_outline, math.pi,null),
            ],
          );
        },
      ),
    );
  }
  Widget _buildOption(IconData icon, double angle, VoidCallback ontap) {
    double iconSize = 0.0;
    if (_animationController.value > 0.8) {
      iconSize = 26.0 * (_animationController.value - 0.8) * 5;
    }
    return GestureDetector(
      child: new Transform.rotate(
        angle: angle,
        child: new Align(
          alignment: Alignment.topCenter,
          child: new Padding(
            padding: new EdgeInsets.only(top: 8.0),
            child: new IconButton(
              onPressed: null,
              iconSize: iconSize,
              icon: new Transform.rotate(
                angle: -angle,
                child: new Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              alignment: Alignment.center,
              padding: new EdgeInsets.all(0.0),
            ),
          ),
        ),
      ),
      onTap: ontap,
    );
  }

  Widget _buildExpandedBackground() {
    double size = hiddenSize + (expandedSize - hiddenSize) * _animationController.value;
    return new Container(
      height: size,
      width: size,
      decoration: new BoxDecoration(shape: BoxShape.circle, color: Colors.pink),
    );
  }

  Widget _buildFabCore() {
    double scaleFactor = 2 * (_animationController.value - 0.5).abs();
    return new FloatingActionButton(
      onPressed: _onFabTap,
      child: new Transform(
        alignment: Alignment.center,
        transform: new Matrix4.identity()..scale(1.0, scaleFactor),
        child: new Icon(
          _animationController.value > 0.5 ? Icons.close : Icons.filter_list,
          color: Colors.white,
          size: 26.0,
        ),
      ),
      backgroundColor: _colorAnimation.value,
    );
  }

  open() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    }
  }

  close() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }

  _onFabTap() {
    if (_animationController.isDismissed) {
      open();
    } else {
      close();
    }
  }
}