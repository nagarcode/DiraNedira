import 'package:flutter/material.dart';

class User {
  const User({
    @required this.uid,
    this.email,
    this.photoUrl,
    this.displayName,
  });
  final String uid;
  final String email;
  final String photoUrl;
  final String displayName;
}
