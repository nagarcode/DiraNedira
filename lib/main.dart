import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/landing_page.dart';
import 'package:dira_nedira/sign_in/apple_sign_in_available.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return Provider<AuthBase>(
      builder: (context) => Auth(),
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
              title: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              subtitle: TextStyle(
                color: Colors.grey,
              ),
              body2: TextStyle(color: Colors.lightBlue),
              display1: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 19,
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
              display2: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
              display3: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              button: TextStyle(color: Colors.white)),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                  title: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        // darkTheme: ThemeData(
        //   // cardColor: Colors.grey[800],
        //   brightness: Brightness.dark,
        //   disabledColor: Colors.grey,
        //   primarySwatch: Colors.lightBlue,
        //   accentColor: Colors.amber[400],
        //   fontFamily: 'Quicksand',
        //   textTheme: ThemeData.light().textTheme.copyWith(
        //       title: TextStyle(
        //         fontFamily: 'OpenSans',
        //         fontSize: 18,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.white,
        //       ),
        //       subtitle: TextStyle(
        //         fontFamily: 'OpenSans',
        //         color: Colors.white70,
        //       ),
        //       button: TextStyle(color: Colors.white)),
        //   appBarTheme: AppBarTheme(
        //     textTheme: ThemeData.light().textTheme.copyWith(
        //           title: TextStyle(
        //             fontFamily: 'OpenSans',
        //             fontSize: 20,
        //             fontWeight: FontWeight.bold,
        //             color: Colors.lightBlue,
        //           ),
        //         ),
        //   ),
        // ),
        home: LandingPage(),
      ),
    );
  }
}
