import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class ThirdBScreen extends StatefulWidget {
  var title;

  // receive data from the FirstScreen as a parameter
  ThirdBScreen({Key key, this.title}) : super(key: key);

  @override
  _ThirdBScreenState createState() {
    return _ThirdBScreenState();
  }
}

class _ThirdBScreenState extends State<ThirdBScreen> {
  _ThirdBScreenState();

  var rand = math.Random(7);

  AudioCache _player = AudioCache();
  final formatter = NumberFormat('00.00');

  Timer _timer; //タイマー
  int _tmcount = 6000; //タイマーカウンター
  double _dtmcount = 60.00; //表示用タイマーカウンター
  int _rncount = 0; //タッチカウンター
  String _resultStr = ''; //ゲーム結果
  var _gameState = 0; //ゲーム終了フラグ

  var alignment = Alignment.center;
  int _botType = 0;

  void _bugMove() {
    switch (_botType) {
      case 1:
        {
          alignment = Alignment.bottomCenter;
        }
        break;
      case 2:
        {
          alignment = Alignment.bottomRight;
        }
        break;
      case 3:
        {
          alignment = Alignment.bottomLeft;
        }
        break;
      case 4:
        {
          alignment = Alignment.topCenter;
        }
        break;
      case 5:
        {
          alignment = Alignment.topRight;
        }
        break;
      case 6:
        {
          alignment = Alignment.topLeft;
        }
        break;
      case 7:
        {
          alignment = Alignment.center;
        }
        break;
      case 8:
        {
        }
        break;
    }
  }

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
        _botType = _tmcount % 2;
        if (_botType == 0) {
          _botType = rand.nextInt(8);
          _bugMove();
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
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: AssetImage(
              'assets/images/GIMP003.png',
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
              //_botType = rand.nextInt(7);
              //_bugMove();
            },
          ),
        ),
      );
    } else {
      return Container(
        //非アクティブ表示
        padding: EdgeInsets.all(8.0),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: AssetImage(
              'assets/images/GIMP003.png',
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
              //_botType = rand.nextInt(7);
              //_bugMove();
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
          Container(
            //背景描画
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/IMG_5616.JPG'),
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
              Expanded(
                child: Container(
                  child: AnimatedAlign(
                    alignment: alignment,
                    duration: Duration(milliseconds: 500),
                    child: _tapeBotun(),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
