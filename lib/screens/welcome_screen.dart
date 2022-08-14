import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/constants.dart';

import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  // STATIC MODIFIER dodamo kako bi varijabla bila asocirana s tom klasom, tako da prilikom dohvaćanja te vrijednosti i implementiranja negdje ne moramo kreirati novi objekt nego samo pozovemo klasu npr. WelcomeScreen.id a ne WelcomeScreen().id
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

// za animacije moramo dodati keyword 'WITH' i SingleTickerProviderStateMixin jer animiramo samo jednu stvar, a da ih je više onda bismo koristili TickerProviderStateMixin
// mixini zapravo daju dodatne mogućnosti klasi, može ih se više dodati
class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
// animation controller

  late AnimationController controller;

// varijabla za curve

  late Animation animation;

  @override
  void initState() {
    super.initState();
    // controller pokrećemo u initStateu
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      // sa this označimo da je klasa zapravo Ticker
      vsync: this,
      // sa upperBound i lowerBound mijenjamo defaultne granice od 0 do 1
      // upperBound: 100.0,
    );
    // inicijaliziramo animaciju
    // parent mora biti animation controller
    // curve koji ćemo koristiti za forward - dodali smo Curves.decelerate sa flutter dokumentacije
    // kada korisimo curve onda ne možemo koristiti upper/lowerBound, mora biti od 0 do 1
    // koristit ćemo animation vrijednost jer se ona zapravo stavlja iznad controllera
    /* animation = CurvedAnimation(parent: controller, curve: Curves.decelerate); */
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);

    // ovo pokreće animaciju naprijed
    controller.forward();
    // LOOP ANIMACIJA
    /* animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse(from: 1.0);
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
      // sa print status saznamo jel animacija completed ili dismissed
      print(status);
    }); */
    // controller.reverse(from: 1.0);

    controller.addListener(() {
      setState(() {});
      // ubacimo print kao callback fciju da vidimo što controller radi - printa vrijednosti od 0 do 1 u istim intervalima
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 60.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                SizedBox(
                  child: DefaultTextStyle(
                    style: kDefaultTextStyle,
                    child: AnimatedTextKit(
                      totalRepeatCount: 3,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Flash Chat',
                          speed: const Duration(milliseconds: 200),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 48.0,
            ),
            // LOGIN BUTTON
            RoundedButton(
              color: kLoginButtonColor,
              title: kLoginButtonTitle,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            // REGISTER BUTTON
            RoundedButton(
              color: kRegisterButtonColor,
              title: kRegisterButtonTitle,
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
