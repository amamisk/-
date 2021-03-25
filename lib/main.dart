import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'animePage.dart';
import 'bugPage.dart';
import 'firstPage.dart';
import 'nextPage.dart';
import 'thirdPage.dart';
import 'endlesP.dart';

void main() async {
  //ファイアベース取得用
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    title: 'Flutter',
    initialRoute: '/animep',
    routes: {
      '/': (context) => DefaultScreen(),
      '/second': (context) => SecondScreen(),
      '/third': (context) => ThirdScreen(),
      '/endless': (context) => EndlessScreen(),
      '/animep': (context) => AnimatedPage(),
      '/bug': (context) => ThirdBScreen(),
    },
  ));
}
