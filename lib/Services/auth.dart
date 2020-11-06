import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DiraUser {
  DiraUser(
      {@required this.uid,
      @required this.disaplayName,
      @required this.photoUrl});
  final String uid;
  final String photoUrl;
  final String disaplayName;

  Map<String, dynamic> dataMap() {
    return {
      'uid': uid,
      'photoUrl': photoUrl,
      'displayName': disaplayName,
    };
  }

  factory DiraUser.fromMap(Map<String, dynamic> data) {
    if (data == null) return null;
    final String uid = data['uid'];
    final String displayName = data['displayName'];
    final String photoUrl = data['photoUrl'];
    return DiraUser(
      uid: uid,
      disaplayName: displayName,
      photoUrl: photoUrl,
    );
  }
}

abstract class AuthBase {
  Stream<DiraUser> get onAuthStateChanged;
  Future<DiraUser> currentUser();
  Future<void> signOut();
  Future<DiraUser> signInWithGoogle();
  Future<DiraUser> signInWithFacebook();
  Future<DiraUser> signInWithApple();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  DiraUser _userFromFirebase(User user) {
    if (user == null) {
      return null;
    }
    return DiraUser(
        uid: user.uid, disaplayName: user.displayName, photoUrl: user.photoURL);
  }

  @override
  Stream<DiraUser> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<DiraUser> currentUser() async {
    final user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  @override
  Future<DiraUser> signInWithFacebook() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(
      ['public_profile', 'email'],
    );
    if (result.accessToken != null) {
      final authResult = await _firebaseAuth.signInWithCredential(
        FacebookAuthProvider.credential(
          result.accessToken.token,
        ),
      );
      return _userFromFirebase(authResult.user);
    } else {
      throw PlatformException(
        code: 'ERROR: ABORTED BY USER',
        message: 'ההתחברות בוטלה ע״י המשתמש',
      );
    }
  }

  @override
  Future<DiraUser> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final authResult = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken),
        );
        return _userFromFirebase(authResult.user);
      } else {
        throw PlatformException(
          code: 'ERROR: MISSING GOOGLE AUTH TOKEN',
          message: 'Missing google auth token',
        );
      }
    } else {
      throw PlatformException(
        code: 'ERROR: ABORTED BY USER',
        message: 'ההתחברות בוטלה ע״י המשתמש',
      );
    }
  }

  @override
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _firebaseAuth.signOut();
    final facebookLogin = FacebookLogin();
    facebookLogin.logOut();
  }

  @override
  Future<DiraUser> signInWithApple(
      {List<Scope> scopes = const [Scope.fullName]}) async {
    // 1. perform the sign-in request
    final result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        final authResult = await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = authResult.user;
        if (firebaseUser.displayName == null) {
          // final updateUser = UserUpdateInfo();
          // updateUser.displayName =
          // appleIdCredential.fullName.givenName;
          await firebaseUser.updateProfile(
              displayName: appleIdCredential.fullName.givenName);
        }
        // if (scopes.contains(Scope.fullName)) {

        // }
        return _userFromFirebase(firebaseUser);
      case AuthorizationStatus.error:
        print(result.error.toString());
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'ההתחברות בוטלה ע״י המשתמש',
        );
    }
    return null;
  }
}
