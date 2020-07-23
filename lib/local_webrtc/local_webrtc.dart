/*
 * @Author GS
 */
/*
 * @Author GS
 */
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';

class LocalWebRTC {
  MediaStream _localStream;
  MediaStream get localStream => _localStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  Map<String, dynamic> mediaConstraints = {
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
  static LocalWebRTC _instance;
  static LocalWebRTC get instance {
    if (_instance == null) _instance = LocalWebRTC();
    return _instance;
  }

  LocalWebRTC() {
    _localRenderer.initialize();
  }

  void dispose() {
    _localRenderer.dispose();
  }

  Future<void> _initUserStream() async {
    _localStream = await navigator.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;
    return;
  }

  Future<void> _initScreenStream() async {
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

    _localStream = await navigator.getDisplayMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;
    return;
  }

  Future<Widget> getLocalRenderingWidget({bool isScreen = false}) async {
    _localStream?.dispose();
    _localRenderer?.dispose();
    if (isScreen) {
      await _initScreenStream();
    } else {
      await _initUserStream();
    }
    return OrientationBuilder(builder: (context, orientation) {
      return RTCVideoView(_localRenderer);
    });
  }
}
