import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/landing_page.dart';
import 'package:dira_nedira/sign_in/apple_sign_in_available.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final appleSignInAvailable = await AppleSignInAvailable.check();

  runApp(
    Provider<AppleSignInAvailable>.value(
        value: appleSignInAvailable, child: DiraNedira()),
  );
}

class DiraNedira extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return Provider<AuthBase>(
      create: (context) => Auth(),
      child: MaterialApp(
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child,
          );
        },
        title: 'Dira Nedira',
        theme: ThemeData(
          disabledColor: Colors.grey,
          primarySwatch: Colors.lightBlue,
          accentColor: Colors.amber[400],
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
                subtitle1: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                subtitle2: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 19,
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.bold,
                ),
                caption: TextStyle(
                  color: Colors.grey,
                ),
                bodyText1: TextStyle(color: Colors.lightBlue),
                headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                headline5: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
                headline4: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                button: TextStyle(color: Colors.white),
              ),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        home: LandingPage(),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
      ),
    );
  }
}
