import 'package:flutter/foundation.dart';

class Apartment {
  String id;
  String password;
  

  Apartment({@required this.id, @required this.password});

  factory Apartment.fromMap(Map<String, dynamic> data, String apartmentId) {
    if (data == null) return null;
    final String id = apartmentId;
    final String password = data['password'];
    return Apartment(
      id: id,
      password: password,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'password': password,
    };
  }

  Map<String, dynamic> idToMap() {
    return {
      'apartmentId': id,
    };
  }

  static String idFromMap(Map<String, dynamic> data) {
    return data['apartmentId'];
  }


}
