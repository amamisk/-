import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SecondScreen extends StatefulWidget {
  var title;

  // receive data from the FirstScreen as a parameter
  SecondScreen({Key key, this.title}) : super(key: key);

  @override
  _SecondScreenState createState() {
    return _SecondScreenState();
  }
}

class _SecondScreenState extends State<SecondScreen> {
  _SecondScreenState();

  AudioCache _player = AudioCache();
  final formatter = NumberFormat('00.00');

  Timer _timer;             //タイマー
  int _tmcount = 1000;      //タイマーカウンター
  double _dtmcount = 10.00; //表示用タイマーカウンター
  int _rncount = 0;         //タッチカウンター
  String _resultStr = '';   //ゲーム結果
  var _gameState = 0;       //ゲーム終了フラグ

  ///タイマースタート
  void _startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_tmcount >= 1) {
          _tmcount = _tmcount - 5;
          _dtmcount = _tmcount / 100;
        } else {
          _timer.cancel();
          _gameState = 1;
        }
      });
    });
  }

  ///タイマーストップ
  void _contSt() {
    if (_rncount != 0) {
      _timer.cancel();
    }
  }

  ///タッチボタンカウント処理
  void _incrementCounter() {
    if (_rncount == 0) {
      _startTimer(); //タッチカウントが０の場合はタイマースタート
    }
    if (_tmcount != 0) {
      _rncount++; //タイマーカウントが０以外はタッチカウント
      _player.play('sound/mizu2.wav');
    } else {
      //タイマーカウント０の場合はゲームオーバーのため無視
    }
  }

  ///タッチボタン描画・及びカウント
  Widget _tapeBotun() {
    if (_gameState == 0) {
      return Container(
        //アクティブ表示
        padding: EdgeInsets.all(8.0),
        width: 90,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: AssetImage(
              'assets/images/akawaku002.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            child: Center(
              child: Text(''),
            ),
            onTap: () {
              _incrementCounter();
            },
          ),
        ),
      );
    } else {
      return Container(
        //非アクティブ表示
        padding: EdgeInsets.all(8.0),
        width: 90,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: AssetImage(
              'assets/images/akawaku001.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            child: Center(
              child: Text(''),
            ),
            onTap: () {
              _incrementCounter();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(//背景描画
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/IMG_7493.JPG'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ///カウントアップ描画
                  Container(
                    child: Text(
                      '${formatter.format(_dtmcount)}',
                      style: TextStyle(
                        fontFamily: 'NotoSerif',
                        fontSize: 50,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  ///戻るボタン描画
                  Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/akawaku002.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Center(
                          child: Text(
                            'QUIT',
                            style: TextStyle(
                              fontFamily: 'NotoSerif',
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onTap: () {
                          _resultStr = _rncount.toString();
                          Navigator.pop(context, '$_resultStr');
                          _contSt(); //戻るボタン押された場合タイマーストップ
                        },
                      ),
                    ),
                  ),
                ],
              ),

              ///タッチカウント描画
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: (_tmcount > 1)
                    ? Text(
                        '$_rncount',
                        style: TextStyle(
                          fontFamily: 'NotoSerif',
                          fontSize: 50,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Time's Up!",
                        style: TextStyle(
                          fontFamily: 'NotoSerif',
                          fontSize: 50,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                      ),
              ),

              ///タッチボタン描画
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        //mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _tapeBotun(),
                          _tapeBotun(),
                          _tapeBotun(),
                          _tapeBotun(),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _tapeBotun(),
                          _tapeBotun(),
                          _tapeBotun(),
                          _tapeBotun(),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _tapeBotun(),
                          _tapeBotun(),
                          _tapeBotun(),
                          _tapeBotun(),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _tapeBotun(),
                          _tapeBotun(),
                          _tapeBotun(),
                          _tapeBotun(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
