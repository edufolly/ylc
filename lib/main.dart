import 'package:flutter/material.dart';
import 'package:ylc/Config.dart';
import 'package:ylc/Login.dart';

///
///
///
void main() {
  bool debug = false;
  assert(debug = true);
  Config.debug = debug;
  runApp(YLC());
}

///
///
///
class YLC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.appName,
      theme: ThemeData.dark().copyWith(
        accentColor: Colors.red,
        primaryColor: Colors.red,
        buttonTheme: ThemeData.dark().buttonTheme.copyWith(
              buttonColor: Colors.red,
            ),
      ),
      home: Login(),
    );
  }
}
