import 'dart:math';
import 'package:dira_nedira/sign_in/apple_sign_in_available.dart';

import '../Services/auth.dart';
import '../common_widgets/platform_exception_alert_dialog.dart';
import '../sign_in/sign_in_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({@required this.bloc, @required this.isLoading});
  final SignInBloc bloc;
  final bool isLoading;
  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      builder: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<SignInBloc>(
          builder: (_) => SignInBloc(auth: auth, isLoading: isLoading),
          child: Consumer<SignInBloc>(
              builder: (context, bloc, _) => SignInScreen(
                    bloc: bloc,
                    isLoading: isLoading.value,
                  )),
        ),
      ),
    );
  }

  void _showSignInError(BuildContext context, PlatformException exception) {
    PlatformExceptionAlertDialog(
      title: 'ההתחברות נכשלה',
      exception: exception,
    ).show(context);
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await bloc.signInWithGoogle();
    } on PlatformException catch (e) {
      if (e.code != 'ההתחברות בוטלה ע״י המשתמש') {
        _showSignInError(context, e);
      }
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await bloc.signInWithFacebook();
    } on PlatformException catch (e) {
      if (e.code != 'ההתחברות בוטלה ע״י המשתמש') {
        _showSignInError(context, e);
      }
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      await bloc.signInWithApple();
    } on PlatformException catch (e) {
      if (e.code != 'ההתחברות בוטלה ע״י המשתמש') {
        _showSignInError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(0, 191, 255, 1).withOpacity(0.5),
                Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, 1],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                    transform: Matrix4.rotationZ(-8 * pi / 180)
                      ..translate(-10.0),
                    // ..translate(-10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: Colors.black26,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      'דירה נדירה',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: 'Anton',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: deviceSize.width > 600 ? 2 : 1,
                  child: Container(
                    height: 260,
                    constraints: BoxConstraints(minHeight: 260),
                    width: deviceSize.width * 0.7,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        if (appleSignInAvailable.isAvailable)
                          SizedBox(
                            width: double.infinity,
                            child: isLoading
                                ? CupertinoActivityIndicator()
                                : SignInButton(
                                    Buttons.Apple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    onPressed: () => _signInWithApple(context),
                                  ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: isLoading
                              ? CupertinoActivityIndicator()
                              : SignInButton(
                                  Buttons.Facebook,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  onPressed: () => _signInWithFacebook(context),
                                ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: isLoading
                              ? CupertinoActivityIndicator()
                              : SignInButton(
                                  Buttons.Google,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  onPressed: () => _signInWithGoogle(context),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
