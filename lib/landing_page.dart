import 'package:dira_nedira/home/home_page.dart';

import './Services/database.dart';
import 'package:provider/provider.dart';
import './splash-screen.dart';
import './Services/auth.dart';
import 'package:flutter/material.dart';
import './sign_in/sign_in_screen.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder<User>(
      stream: auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User user = snapshot.data;
          if (user == null) {
            return SignInScreen.create(context);
          }
          return Provider<User>.value(
            // doesnt need a builder because i just want to provide the user value
            value: user,
            child: Provider<Database>(
              builder: (_) => FirestoreDatabase(uid: user.uid),
              child: HomePage(),
            ),
          );
        } else {
          return SplashScreen();
        }
      },
    );
  }
}
