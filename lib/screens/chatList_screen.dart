import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChatList extends StatefulWidget {
  static String id = 'chatList_screen';
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final _auth = FirebaseAuth.instance;
  final _database = Firestore.instance;
  var loggedUser;
  List<UserCard> usersList = [];
  List<Widget> waiting = [];

  void getUser() async {
    try {
      var user = await _auth.currentUser();
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void getList() async {
    var users = await _database.collection('users').getDocuments();
    for (var user in users.documents) {
      String companionEmail = user.data['email'];
      var userWidget = UserCard(
        user: companionEmail,
        onPressed: () async {
          setState(() {
            showSpinner = true;
          });
          try {
            bool exist;
            var query = await _database
                .collection('$companionEmail&${loggedUser.email}')
                .getDocuments();
            if (query.documents.length > 0)
              exist = true;
            else
              exist = false;

            Navigator.pushNamed(context, ChatScreen.id,
                arguments: [companionEmail, loggedUser.email, exist]);
          } catch (e) {
            print(e);
          } finally {
            setState(() {
              showSpinner = false;
            });
          }
        },
      );
      usersList.add(userWidget);
    }
    setState(() {
      waiting = usersList;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf7c2c2),
      appBar: AppBar(
        title: Text('Chats'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        backgroundColor: Color(0xffc64242),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ListView(
            children: waiting,
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  UserCard({this.user, this.onPressed});

  final user;
  final onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Card(
          color: Color(0xFFE2E1D9),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Color(0xFF221F1B),
              width: 5,
            ),
          ),
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: ListTile(
            leading: Icon(
              Icons.chat_bubble,
              color: Color(0xFF66625D),
            ),
            title: Text(
              user, //loggedUser.email,
              style: TextStyle(
                color: Color(0xFF66625D),
                fontFamily: 'Source Sans Pro',
                fontSize: 20.0,
              ),
            ),
          )),
    );
  }
}
