
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedPage extends StatefulWidget {
  static const routeName = 'animatedAlign';

  @override
  _AnimatedPageState createState() => _AnimatedPageState();
}

class _AnimatedPageState extends State<AnimatedPage> {
  AudioCache _player = AudioCache();

  var _opaque = false;
  int _tmcount = 0; //タイマーカウンター
  Timer _timer;
  int sequence = 0;

  void _startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_tmcount <= 7) {
        _tmcount = _tmcount + 1;
        if (sequence == 0) {
          sequence = 1;
          setState(() {
            _opaque = true;
          });
        }
      } else {
        _timer.cancel();
        sequence = 1;
        Navigator.pushNamed(context, '/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // AppScaffold(
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    if (_opaque != true) {
      _startTimer();
      _player.play('sound/kan_ge_yorusougen01.wav');
    }
    return Scaffold(
      body: Container(
        ///背景画像描画
        height: deviceHeight,
        width: deviceWidth,
        decoration: BoxDecoration(
          color: Colors.black,
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 200,
                width: 200,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 1000),
                  opacity: _opaque ? 1 : 0,
                  child: Image.asset('assets/images/36.png'),
                ),
              ),
              Container(
                height: 200,
                width: 200,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 1000),
                  opacity: _opaque ? 1 : 0.0,
                  child: Image.asset('assets/images/36.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
