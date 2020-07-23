import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_webrtc/local_webrtc/local_webrtc.dart';
import 'package:firebase_webrtc/signaling/signaling.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirebaseWebrtc {
  static const MethodChannel _channel = const MethodChannel('firebase_webrtc');
  CollectionReference dataRef;
  Signaling _signaling = Signaling();
  Signaling get signaling => _signaling;

  FirebaseWebrtc({@required this.dataRef}) {
    _signaling.init(signalingRef: dataRef.document('signaling'));
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<Widget> getLocalMedia({bool isScreen = false}) async {
    return LocalWebRTC.instance.getLocalRenderingWidget(isScreen: isScreen);
  }
}
