import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import '../components/rounded_button.dart';
// 1. import firebase auth for user authentification
import 'package:firebase_auth/firebase_auth.dart';
// importamo hud
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  //2. create new auth instance in reg screen state - private property
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  // bool for the spinner
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // wrap all the widgets in the hud widget
      body: ModalProgressHUD(
        // required property
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              // EMAIL INPUT
              TextField(
                // with the keyboardType property we changed the phone keyboad to show @ sign while typing the email
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                  //Do something with the user input.
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              const SizedBox(
                height: 8.0,
              ),
              // PASSWORD INPUT
              TextField(
                // with the obscureText property hide the password value and instead show dots
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                  //Do something with the user input.
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password...'),
              ),
              const SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: kRegisterButtonColor,
                title: kRegisterButtonTitle,
                onPressed: () async {
                  // with the set state we change the spinner value
                  setState(() {
                    showSpinner = true;
                  });
                  print(email);
                  print(password);
                  // 3. register our user with the associated method  createUserWithEmailAndPassword that takes two properties ( email and password that we created earlier as Strings) and because it returns a Future we can save it in a new variable called newUser for later use, we need to add the async modifier to the onPressed property and set the await keyword to the newUser value
                  // we add the try and catch blocks so we can check if the user provided the correct email and password
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser != null) {
                      //4. if everything is OK we send the user to the chat screen - the user is actually saved inside the _auth variable
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
