import 'package:flash_chat/components/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
//5. import the auth package in the chat screen
import 'package:firebase_auth/firebase_auth.dart';
// 1) to add data to the firestore database we need to import the cloud firestore package
import 'package:cloud_firestore/cloud_firestore.dart';

// 4) create a new instance of firestore
final _firestore = FirebaseFirestore.instance;
// loggedInUser is the variable that holds the data of the user (email, password...)
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
// text editing controller
  final messageTextController = TextEditingController();

// 6. create new instance in the chat screen
  final _auth = FirebaseAuth.instance;

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

  // method to get the messages sent to the firestore, same as adding data to the firestore we initialize our private firestore variable and access our collection called messages, then we call the method 'get()' that retrieves a snapshot (future)
  void getMessages() async {
    // we go into our firestore db, our collection and with the method get we get all the data, save it into the messages variable
    final messages = await _firestore.collection('messages').get();
    // because the messages in firestore are a list we create a for in loop to get the messages values that are stored in the messages and they are accessed with the .docs
    for (var message in messages.docs) {
      // 'data' keyword gives us the key:value pair
      print(message.data());
    }
  }

  //  a) STREAM - we subscribe to the stream and listen to the changes in the database
  // loop through the snapshots (firebase's query snapshot)
  /* void messagesStream() async {
    // b) instead using the get() method we use the snapshots() method that retrieves data, it's kinda like a list of future, a whole bunch of futures and because we are subscribed we are notified if there is a change in the db
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      // snapshot.docs gives us all the documents in the snapshot
      for (var message in snapshot.docs) {
        // data gives us the key:value pair
        print(message.data());
      }
    }
  } */

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
                // getMessages();
                // use the signOut method on the _auth
                _auth.signOut();

                //messagesStream();
                // pop the user on the previous screen
                Navigator.pop(context);
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
            // b) we create a new widget that holds our stream of data
            const MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    // CHAT TEXT FIELD
                    child: TextField(
                      controller: messageTextController,
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
                      // we call the controller to clear the text field after pressing the send button
                      messageTextController.clear();
                      //messageText + loggedinUser.email
                      // 5) to send data we need to intialize our instance and add the 'collection' method that expects a String and that is the name of the collection on firestore! Then we use the 'add' method which expects a key:value pair => Map<String, dynamic>,
                      _firestore.collection('messages').add(
                        {
                          //6) the first key is the 'text' as we specified in our firestore and the data is the messageText variable; and the other one is the 'sender' is the email adress of the loggedinUser variable
                          'text': messageText, 'sender': loggedInUser.email,
                          "time": DateTime.now()
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

class MessagesStream extends StatelessWidget {
  const MessagesStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return // b) in the streambuilder we provide the snapshots to show our messages; it has two properties, 'stream' from where the data is going to come from and in this case we use our firestore.collection('messages).snapshots() because snapshots are a stream of query snapshots(it's a firebase class that contains the messages we are after ), and 'builder' that has AysncSnapshots (where our messages are saved); and we create an anonymous function that has context and snaphost(flutter async snapshot not the same as the one before) as properties
        //streambuilder automatically calls setState when new data comes in

        StreamBuilder<QuerySnapshot>(
      builder: (context, snapshot) {
        // first we check if the snapshot has data with the method .hasData and if it does we use that data
        if (!snapshot.hasData) {
          // show a spinner while data is being loaded or there is no data
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else {
          //we get the data in the messages variable, docs are a list of documents + at the end we added the reversed so it will reverse the order of the list so the new message will be shown on the very bottom of the list view
          final messages = snapshot.data!.docs.reversed;
          //we use a for loop to iterate through the list of documents and create a list of new widgets
          List<MessageBubble> messageWidgets = [];
          for (var message in messages) {
            // the data is not the same as before - this one is from firebase and the one before is from flutter
            Map<String, dynamic> fireData =
                // we are returning the data from firebase as a map and saving it into the new Map = fireData;
                message.data() as Map<String, dynamic>;
            // accessing the fireData (firestore db) with our keys to retrieve the values;
            final messageText = fireData['text'];
            final messageSender = fireData['sender'];
            final messageTime = fireData['time'];
            // check to see if the loggedinUser is the current user
            final currentUser = loggedInUser.email;

            // checker to see if we are getting the data
            /* print(messageText);
                    print(messageSender); */
            // creating our new text widget and pushing it to the text widgets list
            final messageWidget = MessageBubble(
              messageSender: messageSender,
              messageText: messageText,
              time: messageTime,
              isMe: currentUser == messageSender,
            );
            messageWidgets.add(messageWidget);
            // sort the messages by time they've been sent
            messageWidgets.sort((a, b) => b.time.compareTo(a.time));
          }
          // returning a column with all the data from firebase db
          // OUR LIST VIEW THAT CONTAINES MESSAGES SHOW ON THE SCREEN
          return Expanded(
            child: ListView(
              // reverse true makes the messages sticky to the bottom
              reverse: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              children: messageWidgets,
            ),
          );
        }
      },
      stream: _firestore.collection('messages').snapshots(),
    );
  }
}
