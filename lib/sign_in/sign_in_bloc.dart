import 'dart:async';
import 'package:dira_nedira/Services/auth.dart';
import 'package:flutter/foundation.dart';

class SignInBloc {
  SignInBloc({@required this.auth, @required this.isLoading});
  final AuthBase auth;
  final ValueNotifier<bool> isLoading;

  Future<DiraUser> _signIn(Future<DiraUser> Function() signInMethod) async {
    // final firebaseMessaging = FirebaseMessaging();
    try {
      isLoading.value = true;
      final user = await signInMethod();
      // final fcmToken = await firebaseMessaging.getToken();
      // final database = FirestoreDatabase(uid: user.uid);
      // database.addFcmToken(uid: user.uid, token: fcmToken);
      return user;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    } finally {}
  }

  Future<DiraUser> signInWithGoogle() async =>
      await _signIn(auth.signInWithGoogle);

  Future<DiraUser> signInWithFacebook() async =>
      await _signIn(auth.signInWithFacebook);

  Future<DiraUser> signInWithApple() async =>
      await _signIn(auth.signInWithApple);
}
