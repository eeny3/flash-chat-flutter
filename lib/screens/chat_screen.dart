import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var textController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _database = Firestore.instance;
  String messageText;

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context).settings.arguments;
    String companionEmail = args[0];
    String loggedUserEmail = args[1];
    bool ifChatAlreadyExist = args[2];

    return Scaffold(
      backgroundColor: Color(0xFFf7c2c2),
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //_auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('$companionEmail'),
        backgroundColor: Color(0xffc64242),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: ifChatAlreadyExist
                  ? _database
                      .collection('$companionEmail&$loggedUserEmail')
                      .orderBy('ts', descending: true)
                      .snapshots()
                  : _database
                      .collection('$loggedUserEmail&$companionEmail')
                      .orderBy('ts', descending: true)
                      .snapshots(),
              // ,
              // ignore: missing_return
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = snapshot.data.documents; //.reversed;
                List<Bubble> messageWidgets = [];
                for (var message in messages) {
                  var messageText = message.data['text'];
                  var messageSender = message.data['sender'];
                  var currentUser = loggedUserEmail;
                  var messageWidget = Bubble(
                    text: messageText,
                    sender: messageSender,
                    isME: currentUser == messageSender,
                  );
                  messageWidgets.add(messageWidget);
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    children: messageWidgets,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textController.clear();
                      String collName = ifChatAlreadyExist
                          ? '$companionEmail&$loggedUserEmail'
                          : '$loggedUserEmail&$companionEmail';
                      _database.collection(collName).add({
                        'text': messageText,
                        'sender': loggedUserEmail,
                        'ts': FieldValue.serverTimestamp(),
                      });
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  Bubble({this.text, this.sender, this.isME});
  final String sender;
  final String text;
  final bool isME;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isME ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Material(
            borderRadius: isME
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            elevation: 5,
            color: isME ? Color(0xFFD53539) : Color(0xFFF0E4D8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                    color: isME ? Colors.white : Colors.black54, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
