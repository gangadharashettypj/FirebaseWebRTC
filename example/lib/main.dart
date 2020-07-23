import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_webrtc/firebase_webrtc.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  FirebaseWebrtc firebaseWebrtc =
      FirebaseWebrtc(dataRef: Firestore.instance.collection('classroom'));
  Widget localWidget;

  @override
  void initState() {
    super.initState();
  }

  TextEditingController roomNameController = TextEditingController();
  String error = '';
  String userId = 'USER1';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                'User ID: $userId',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 30, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Set User 1'),
                    onPressed: () {
                      setState(() {
                        userId = 'USER1';
                      });
                    },
                  ),
                  RaisedButton(
                    child: Text('Set User 2'),
                    onPressed: () {
                      setState(() {
                        userId = 'USER2';
                      });
                    },
                  ),
                  RaisedButton(
                    child: Text('Set User 3'),
                    onPressed: () {
                      setState(() {
                        userId = 'USER3';
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: 200,
              height: 200,
              child: localWidget ?? Container(),
            ),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: TextField(
                  controller: roomNameController,
                  decoration: InputDecoration(
                    hintText: 'Room Name',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  child: Text('Create Room'),
                  onPressed: () async {
                    if (roomNameController.text == '' ||
                        roomNameController.text == null) {
                      setState(() {
                        error = 'Error: Please enter a valid room name';
                      });
                      return;
                    } else if (error != '') {
                      setState(() {
                        error = '';
                      });
                    }
                    bool roomCreated = await firebaseWebrtc.signaling.create(
                      roomNameController.text,
                      userId,
                    );
                    if (roomCreated) {
                      getWidget();
                    }
                  },
                ),
                RaisedButton(
                  child: Text('Join Room'),
                  onPressed: () async {
                    if (roomNameController.text == '' ||
                        roomNameController.text == null) {
                      setState(() {
                        error = 'Error: Please enter a valid room name';
                      });
                      return;
                    } else if (error != '') {
                      setState(() {
                        error = '';
                      });
                    }
                    bool roomExist = await firebaseWebrtc.signaling.joinRoom(
                      roomNameController.text,
                      userId,
                    );
                    if (roomExist) {
                      getWidget();
                    } else {
                      setState(() {
                        error = 'Error: Room doesnot exist';
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('Present Room'),
                  onPressed: () async {
                    if (roomNameController.text == '' ||
                        roomNameController.text == null) {
                      setState(() {
                        error = 'Error: Please enter a valid room name';
                      });
                      return;
                    } else if (error != '') {
                      setState(() {
                        error = '';
                      });
                    }
                    bool roomExist = await firebaseWebrtc.signaling.presentRoom(
                      roomNameController.text,
                      userId,
                    );
                    if (roomExist) {
                      getWidget();
                    } else {
                      setState(() {
                        error = 'Error: Room doesnot exist';
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('Close Room'),
                  onPressed: () async {
                    if (roomNameController.text == '' ||
                        roomNameController.text == null) {
                      setState(() {
                        error = 'Error: Please enter a valid room name';
                      });
                      return;
                    } else if (error != '') {
                      setState(() {
                        error = '';
                      });
                    }

                    await firebaseWebrtc.signaling.deleteRoom(
                      roomNameController.text,
                    );
                  },
                ),
              ],
            ),
            Text(
              '$error',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getWidget() async {
    var temp = await firebaseWebrtc.getLocalMedia(isScreen: false);
    setState(() {
      print("widget found");
      localWidget = temp;
    });
  }
}
