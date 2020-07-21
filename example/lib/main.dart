import 'package:firebase_webrtc/firebase_webrtc.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseWebrtc firebaseWebrtc = FirebaseWebrtc();
  Widget localWidget;
  @override
  void initState() {
    firebaseWebrtc.init();
    getWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: localWidget ?? Container(),
    );
  }

  void getWidget() async {
    var temp = await firebaseWebrtc.getLocalRenderingWidget();
    setState(() {
      localWidget = temp;
    });
  }
}
