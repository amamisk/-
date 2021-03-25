import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';

import 'main_sql_db.dart';
import 'main_db.dart';

class DefaultScreen extends StatefulWidget {
  @override
  _DefaultScreenState createState() {
    return _DefaultScreenState();
  }
}

class _DefaultScreenState extends State<DefaultScreen> {
  MainDBRank _mainDBRank = MainDBRank();
  Main_SQL_DB _main_SQL_DB = Main_SQL_DB();
  AudioCache _player = AudioCache();

  @override
  // ignore: must_call_super
  void initState() {
    _mainDBRank.getRankListRealtime('bady');
  }

  var rankNum = '1.\n2.\n3.\n4.\n5.\n6.\n7.\n8.\n9.\n10.';
  static const gMode10 = 1;
  static const gMode60 = 2;
  static const gModeEND = 3;

  int _gameMode = gMode10; //モードフラグ
  String _addtext = ''; //名前テキスト
  String _routestxt = '/second'; //画面ルート用TXT

  int _sqlDBid = 0;//SQLデータベースID
  bool _newGamePlayer = false;//プレヤー名がSQLDB内の記録有無フラグ
  int _newNum = 0;//ゲーム結果成績

  //個人成績ゲーム結果
  String _result10 = '';
  String _result60 = '';
  String _resultEndless = '';

  //個人成績描画用
  String _redraw10 = '---';
  String _redraw60 = '---';
  String _redrawEnd = '---';

  //個人成績過去結果
  String _beforeName = '';
  String _before10 = '---';
  String _before60 = '---';
  String _beforeEnd = '---';

  //テキストフィールド名前入力処理
  void _handleText(String _e) {
    setState(() {
      _addtext = _e;
    });
  }



  ///ゲーム戻り値String→int変換
  void _resultChange(String _result) {
    try {
      _newNum = int.parse(_result);
    } catch (exception) {
      _newNum = 1;
    }
  }

  ///個人成績
  void _readCounter(String _result) {
    print('_readCounter $_result');
    int oldNum;

    ///登録なしプレイヤー判定
    if (_newGamePlayer == true) {
      _main_SQL_DB.saveData(_addtext, '', '', '');
      _newGamePlayer = false;
    }

    ///過去値取得
    _result10 = _before10;
    _result60 = _before60;
    _resultEndless = _beforeEnd;

    ///ゲームモードごとに個人成績取得
    if (_gameMode == gMode10) {
      try {
        oldNum = int.parse(_result10);
      } catch (exception) {
        oldNum = 1;
      }
      if (oldNum < _newNum) {
        _result10 = _result;
      }
    } else if (_gameMode == gMode60) {
      try {
        oldNum = int.parse(_result60);
      } catch (exception) {
        oldNum = 1;
      }
      if (oldNum < _newNum) {
        _result60 = _result;
      }
    } else {
      try {
        oldNum = int.parse(_resultEndless);
      } catch (exception) {
        oldNum = 1;
      }
      if (oldNum < _newNum) {
        _resultEndless = _result;
      }
    }

    ///SQL DB更新
    _main_SQL_DB.updateItems(_sqlDBid, _addtext, _result10, _result60, _resultEndless);

    ///表示更新
    setState(() {
      _redraw10 = _result10;
      _redraw60 = _result60;
      _redrawEnd = _resultEndless;
    });
  }

  /// 個人成績SQLデータベース取得
  void _getSQLChange() async {
    print('_getSQLChange');
    final cx = await _main_SQL_DB.queryRowCount();//データ件数取得

    if (cx == 0) {
      //SQL登録が0の場合
      _newGamePlayer = true; //登録なしは新規
      _sqlDBid = 1;
      _beforeName = _addtext;
      _before10 = '---';
      _before60 = '---';
      _beforeEnd = '---';
    } else {
      //SQL登録有り時
      final allRows = await _main_SQL_DB.getItems();
      int c = 0;
      for (Map item in allRows) {
        //SQLデータベース上からプレイヤー有無判定
        if (allRows[c]['name'] == _addtext) {
          print('_getSQLChange ${allRows[c]}');
          _newGamePlayer = false; //登録ありは上書き
          _sqlDBid = allRows[c]['id'];
          _beforeName = allRows[c]['name'];
          _before10 = allRows[c]['ten'];
          _before60 = allRows[c]['six'];
          _beforeEnd = allRows[c]['end'];
          break;
        } else {
          _newGamePlayer = true; //登録なしは新規
          _sqlDBid = allRows[c]['id'];
          _sqlDBid++;
          _beforeName = _addtext;
          _before10 = '---';
          _before60 = '---';
          _beforeEnd = '---';
        }
        c++;
      }
    }

    ///表示更新
    setState(() {
      _redraw10 = _before10;
      _redraw60 = _before60;
      _redrawEnd = _beforeEnd;
    });
  }

  ///ランキング更新判定
  void _readRnking() async {
    int cp = 0;

    ///ランキング登録数をカウント
    for (int i = 0; i < _mainDBRank.rankList.length; i++) {
      cp++;
    }

    ///ランキングの空きチェック、ランキング最下位と比較してランキング追加
    if (cp >= 10) {
      if (_mainDBRank.rankList[9].votes < _newNum) {
        ///アイテムチェックしてランキング削除・ランキング追加
        switch (_gameMode) {
          case gMode10:
            {
              await _mainDBRank.deleteBook(_mainDBRank.rankList, 'bady');
            }
            break;
          case gMode60:
            {
              await _mainDBRank.deleteBook(_mainDBRank.rankList, 'rankList');
            }
            break;
          case gModeEND:
            {
              await _mainDBRank.deleteBook(_mainDBRank.rankList, 'rankList2');
            }
            break;
        }
        _mainDBRank.newRankName = _beforeName;
        _mainDBRank.newRankScore = _newNum;
        switch (_gameMode) {
          case gMode10:
            {
              await _mainDBRank.add('bady');
            }
            break;
          case gMode60:
            {
              await _mainDBRank.add('rankList');
            }
            break;
          case gModeEND:
            {
              await _mainDBRank.add('rankList2');
            }
            break;
        }
      }
    } else {
      ///ランキングに空きがあれば、評価無しでランキング追加
      _mainDBRank.newRankName = _beforeName;
      _mainDBRank.newRankScore = _newNum;
      switch (_gameMode) {
        case gMode10:
          {
            await _mainDBRank.add('bady');
          }
          break;
        case gMode60:
          {
            await _mainDBRank.add('rankList');
          }
          break;
        case gModeEND:
          {
            await _mainDBRank.add('rankList2');
          }
          break;
      }
    }

    ///サーバ情報再取得
    _mainDBRank.fetchBooks();
  }

  ///スタッフ、ランキング表示作成
  Widget _mDBRank(BuildContext context) {
    List recordName =
    _mainDBRank.rankList.map((data) => data.rankingTxt).toList();

    return Expanded(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ///スタッフテキスト表示
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'SOUND EFFECT:\n'
                  'あああああああ\n'
                  '\n'
                  'FONT:\n'
                  'デフォルト\n'
                  '\n'
                  'ICON:\n'
                  'デフォルト\n'
                  '\n'
                  'BACK GROUND:\n'
                  'Hiroki Icikawa\n'
                  '\n'
                  'SPECIAL THANKS\n'
                  'みなさま\n'
                  '\n'
                  '(c)2021 xxxxxxx',
                  style: TextStyle(
                    fontFamily: 'NotoSerif',
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            ///ランキング画像、テキスト表示
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 220,
                  width: 220,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/34.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontFamily: 'NotoSerif',
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "$rankNum",
                            style: TextStyle(
                              fontFamily: 'NotoSerif',
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: recordName
                                .map(
                                  (recordName) => Text(
                                    "${recordName}",
                                    style: TextStyle(
                                      fontFamily: 'NotoSerif',
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FontStyle.normal,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///個人成績テキスト作成
  Widget _headerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '10s',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                '$_redraw10',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '60s',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text('$_redraw60',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  )),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'ENDLESS',
                style: TextStyle(
                  fontFamily: 'NotoSerif',
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
              Text('$_redrawEnd',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  ///タイトルテキスト
  Widget _titleSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      child: Column(
        children: [
          Text(
            'Renda',
            style: TextStyle(
              fontFamily: 'NotoSerif',
              fontSize: 50,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              color: Colors.white,
            ),
          ),
          Text(
            'Machine',
            style: TextStyle(
              fontFamily: 'NotoSerif',
              fontSize: 50,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// モードボタン表示切替
  Widget _fooBotun(int _botType) {
    String botText = '10s';
    String rtxt = '/second';
    String fireText = 'bady';

    ///ボタンタイプごとに初期化
    switch (_botType) {
      case gMode10:
        {
          botText = '10s';
          rtxt = '/second';
          fireText = 'bady';
        }
        break;
      case gMode60:
        {
          botText = '60s';
          rtxt = '/third';
          fireText = 'rankList';
        }
        break;
      case gModeEND:
        {
          botText = 'ENDLESS';
          rtxt = '/endless';
          fireText = 'rankList2';
        }
        break;
    }

    ///ボタン作成、現在のモードと一致する場合、強調表示
    if (_gameMode == _botType) {
      return Container(
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
              child: Text(
                botText,
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
              setState(() {
                _mainDBRank.getRankListRealtime(fireText);//ランキング表示更新
                _gameMode = _botType;//タップされたらモード更新
                _routestxt = rtxt;//画面遷移ルート設定
              });
            },
          ),
        ),
      );
    } else {
      return Container(
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
              child: Text(
                botText,
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
              setState(() {
                _mainDBRank.getRankListRealtime(fireText);//ランキング表示更新
                _gameMode = _botType;//タップされたらモード更新
                _routestxt = rtxt;//画面遷移ルート設定
                _player.play('sound/knok.wav');//音再生
              });
            },
          ),
        ),
      );
    }
  }

  ///モード選択ボタン
  Widget _selectSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _fooBotun(gMode10),
          _fooBotun(gMode60),
          _fooBotun(gModeEND),
        ],
      ),
    );
  }

  ///ゲーム開始ボタン
  Widget _underSection(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 300,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/akawaku003.png',
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
                    'PLAY!',
                    style: TextStyle(
                      fontFamily: 'NotoSerif',
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () async {
                  var resultT =
                      await Navigator.pushNamed(context, '$_routestxt');
                  _resultChange(resultT);//String→int変換
                  _readCounter(resultT);//個人成績最高得点判定
                  _getSQLChange();//SQLデータとマージ
                  _readRnking();//サーバランキング更新判定
                },
                onLongPress: () async {
                  var resultT =
                  await Navigator.pushNamed(context, '/bug');
                  _resultChange(resultT);//String→int変換
                  _readCounter(resultT);//個人成績最高得点判定
                  _getSQLChange();//SQLデータとマージ
                  _readRnking();//サーバランキング更新判定
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///実体描画
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container( //背景画像描画
              height: deviceHeight,
              width: deviceWidth,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: AssetImage('assets/images/IMG_7493.JPG'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  ///個人成績
                  _headerSection(context),

                  ///タイトル部分
                  _titleSection(context),

                  ///入力フォーム
                  Container(
                    width: 200,
                    height: 40,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Colors.white.withOpacity(0.6),
                        filled: true,
                        hintText: 'EnterNickname...',
                      ),
                      textAlign: TextAlign.center,
                      onChanged: _handleText,
                      onFieldSubmitted: (String value) {
                        _mainDBRank.getRankListRealtime('bady');
                        _getSQLChange();//SQLからプレイヤー確認と個人成績読み込み
                      },
                    ),
                  ),

                  ///モード選択
                  Center(
                    child: (_addtext == '') ? Text('') : _selectSection(context),
                  ),

                  ///開始ボタン
                  Center(
                    child: (_addtext == '') ? Text('') : _underSection(context),
                  ),

                  ///スタッフ、ランキング表示
                  _mDBRank(context),

                  ///作成日表示
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '2021.3.24',
                      style: TextStyle(
                        fontFamily: 'NotoSerif',
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
