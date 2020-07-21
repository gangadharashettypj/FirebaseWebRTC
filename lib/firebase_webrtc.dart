import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/get_user_media.dart';
import 'package:flutter_webrtc/media_stream.dart';
import 'package:flutter_webrtc/rtc_peerconnection.dart';
import 'package:flutter_webrtc/rtc_video_view.dart';

class FirebaseWebrtc {
  static const MethodChannel _channel = const MethodChannel('firebase_webrtc');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  MediaStream _localStream;
  MediaStream _localScreenStream;
  MediaStream _remoteStream;
  RTCPeerConnection peerConnection;

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  Future<MediaStream> get getLocalStream async {
    if (_localStream == null) {
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };

      _localStream = await navigator.getUserMedia(mediaConstraints);
    }
    return _localStream;
  }

  void init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _initLocalStream();
  }

  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void _initLocalStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    _localStream = await navigator.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;
//    _localScreenStream = await navigator.getDisplayMedia(mediaConstraints);
  }

  Future<MediaStream> get getLocalScreenStream async {
    if (_localScreenStream == null) {
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };
      _localScreenStream = await navigator.getDisplayMedia(mediaConstraints);
    }
    return _localScreenStream;
  }

  Future<Widget> getLocalRenderingWidget({bool isScreen = false}) async {
    return OrientationBuilder(builder: (context, orientation) {
      return RTCVideoView(isScreen ? _localScreenStream : _localRenderer);
    });
  }
}
