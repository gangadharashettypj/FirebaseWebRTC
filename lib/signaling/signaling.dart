/*
 * @Author GS
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_webrtc/local_webrtc/local_webrtc.dart';
import 'package:flutter_webrtc/webrtc.dart';

class Signaling {
  DocumentReference signalingRef;
  RTCPeerConnection rtcPeerConnection;
  Map<String, dynamic> iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun.services.mozilla.com'},
    ]
  };
  bool isPresenter = false;
  Future<bool> create(String roomName, String uid) async {
    bool roomCreated = false;
    await signalingRef
        .collection('rooms')
        .document(roomName)
        .get()
        .then((value) async {
      if (!value.exists) {
        print('room not exist, creating');
        await signalingRef.collection('rooms').document(roomName).setData({
          'date_time': DateTime.now().millisecondsSinceEpoch,
          'owner': uid,
          'room_name': roomName,
          'status': 0,
          'presenter': null,
        });
      }
      roomCreated = true;
    });

    return roomCreated;
  }

  Future<void> deleteRoom(String roomName) async {
    await signalingRef.collection('rooms').document(roomName).delete();
  }

  Future<bool> joinRoom(String roomName, String uid) async {
    bool roomExist = false;
    await signalingRef
        .collection('rooms')
        .document(roomName)
        .get()
        .then((value) async {
      if (!value.exists) {
        roomExist = false;
      } else {
        print('room created or joined');
        await signalingRef
            .collection('rooms')
            .document(roomName)
            .collection('users')
            .document(uid)
            .setData({
          'datetime': DateTime.now().millisecondsSinceEpoch,
          'active': true,
          'user_id': uid,
        });
        initListners(roomName, uid);
        roomExist = true;
      }
    });

    return roomExist;
  }

  Future<bool> presentRoom(String roomName, String uid) async {
    bool roomExist = false;
    await signalingRef
        .collection('rooms')
        .document(roomName)
        .get()
        .then((value) async {
      if (!value.exists) {
        roomExist = false;
      } else {
        print('room created or joined');
        await signalingRef.collection('rooms').document(roomName).updateData({
          'status': 1,
          'presenter': uid,
        });
        isPresenter = true;
        initListners(roomName, uid);
        roomExist = true;
      }
    });

    return roomExist;
  }

  init({DocumentReference signalingRef}) {
    this.signalingRef = signalingRef;
  }

  void setStatus(String roomName, dynamic data) {
    signalingRef.collection('rooms').document(roomName).updateData({
      'status': data,
    });
  }

  void setCandidate(String roomName, dynamic data) {
    signalingRef.collection('rooms').document(roomName).setData({
      'candidate': null,
    });
  }

  void setOffer(String roomName, dynamic data) {
    signalingRef.collection('rooms').document(roomName).setData({
      'offer': null,
    });
  }

  void setAnswer(String roomName, dynamic data) {
    signalingRef.collection('rooms').document(roomName).setData({
      'answer': null,
    });
  }

  void initListners(String roomName, String uid) async {
    signalingRef
        .collection('rooms')
        .document(roomName)
        .collection('users')
        .snapshots()
        .listen((event) {
      event.documentChanges.forEach((element) {
        print('Room Users: ' + element.document.data.toString());
        if (isPresenter) {
          rtcPeerConnection = RTCPeerConnection(
            DateTime.now().millisecondsSinceEpoch.toString(),
            iceServers,
          );
          rtcPeerConnection.onIceCandidate = onIceCandidate;
          rtcPeerConnection.onAddStream = onAddStream;
          rtcPeerConnection.addStream(LocalWebRTC.instance.localStream);
          rtcPeerConnection
              .createOffer(LocalWebRTC.instance.mediaConstraints)
              .then((description) {
            rtcPeerConnection.setLocalDescription(description);
            element.document.reference.setData({
              'offer': {
                'type': 'offer',
                'sdp': description,
                'room': roomName,
              }
            });
          });
        }
      });
    });
    signalingRef
        .collection('rooms')
        .document(roomName)
        .collection('users')
        .document(uid)
        .snapshots()
        .listen((event) {
      if (event.data.containsKey('offer') &&
          !event.data.containsKey('answer')) {
        if (!isPresenter) {
          rtcPeerConnection = RTCPeerConnection(
            DateTime.now().millisecondsSinceEpoch.toString(),
            iceServers,
          );
          rtcPeerConnection.onIceCandidate = onIceCandidate;
          rtcPeerConnection.onAddStream = onAddStream;
          rtcPeerConnection.addStream(LocalWebRTC.instance.localStream);
          rtcPeerConnection.setRemoteDescription(
            RTCSessionDescription(
              event.data['offer']['sdp'],
              event.data['offer']['type'],
            ),
          );
          rtcPeerConnection
              .createAnswer(LocalWebRTC.instance.mediaConstraints)
              .then((description) {
            rtcPeerConnection.setLocalDescription(description);
            event.reference.setData({
              'answer': {
                'type': 'answer',
                'sdp': description,
                'room': roomName,
              }
            });
          });
        }
      }
    });

    signalingRef
        .collection('rooms')
        .document(roomName)
        .snapshots()
        .listen((event) {
      print('Room MetaData: ' + event.data.toString());
    });
    return;
  }

  void onIceCandidate(RTCIceCandidate candidate) {}

  void onAddStream(MediaStream stream) {}
}
