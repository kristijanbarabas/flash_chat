import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
//5. import the auth package in the chat screen
import 'package:firebase_auth/firebase_auth.dart';
// 1) to add data to the firestore database we need to import the cloud firestore package
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
// 4) create a new instance of firestore
  final _firestore = FirebaseFirestore.instance;
// 6. create new instance in the chat screen
  final _auth = FirebaseAuth.instance;
  // loggedInUser is the variable that holds the data of the user (email, password...)
  late User loggedInUser;
  // 2) save what the user types in a variable
  late String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  //7. create a method to receive the current user to check if there is a current user who is signed in
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // method to get the messages sent to the firestore, same as adding data to the firestore we initilaize our private firestore variable and accsess our collection called messages, then we call the method 'get()'
  /*  void getMessages() async {
    final messages = await _firestore.collection('messages').get();
    // because the messages in firestore are a list we create a for in loop to get the messages values
    for (var message in messages.docs) {
      // data gives us the key:value pair
      print(message.data());
    }
  } */

  // STREAM - we subsrcribe to the stream and listen to the changes in the database
  // loop through the snapshots
  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        // data gives us the key:value pair
        print(message.data());
      }
      ;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: null,
        actions: <Widget>[
          // X BUTTON ICON
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // use the signOut method on the _auth
                // _auth.signOut();

                messagesStream();
                // pop the user on the previous screen
                // Navigator.pop(context);
                //Implement logout functionality
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // in the streambuilder we provide the snapshots
            StreamBuilder(builder: , stream: _firestore.collection('messages').snapshots(),),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    // CHAT TEXT FIELD
                    child: TextField(
                      onChanged: (value) {
                        // 3)SET THE VALUE OF THE CHAT TO THE CREATED VARIABLE
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  // SEND BUTTON
                  TextButton(
                    onPressed: () {
                      //messageText + loggedinUser.email
                      // 5) to send data we need to intialize our instance and add the 'collection' method that expects a String and that is the name of the collection on firestore! Then we use the 'add' method which expects a key:value pair => Map<String, dynamic>,
                      _firestore.collection('messages').add(
                        {
                          //6) the first key is the 'text' as we specified in our firestore and the data is the messageText variable; and the other one is the 'sender' is the email adress of the loggedinUser variable
                          'text': messageText, 'sender': loggedInUser.email,
                        },
                      );
                    },
                    child: const Text(
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
