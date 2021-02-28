import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Investment {
  String title;
  int amount;
  DateTime date;
  String id;
  String ownerUid;
  String ownerPhotoUrl;
  int colorIndex;
  String imageURL;

  static final Map<Color, String> colors = {
    Colors.deepPurple[100]: 'חשבונות',
    Colors.lime[200]: 'קניות',
    Colors.lightBlue[100]: 'כללי',
    Colors.deepOrange[100]: 'משלוח אוכל',
    Colors.teal[100]: 'חיות מחמד',
  };
  Color color() {
    return colors.keys.toList()[colorIndex];
  }

  Investment({
    @required this.title,
    @required this.amount,
    @required this.date,
    @required this.id,
    @required this.ownerUid,
    @required this.ownerPhotoUrl,
    @required this.colorIndex,
    @required this.imageURL,
  });

  factory Investment.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) return null;
    final String title = data['title'];
    final int amount = data['amount'];
    final DateTime date = data['date'].toDate();
    final String ownerUid = data['ownerUid'];
    final String ownerPhotoUrl = data['ownerPhotoUrl'];
    final int colorIndex = data['colorIndex'] ?? 2;
    final String imageURL = data['imageURL'] ?? null;
    return Investment(
      amount: amount,
      title: title,
      date: date,
      id: documentId,
      ownerUid: ownerUid,
      ownerPhotoUrl: ownerPhotoUrl,
      colorIndex: colorIndex,
      imageURL: imageURL,
    );
  }
  static List<Investment> fromDocument(Map<String, dynamic> doc) {
    List<Investment> list = [];
    doc.forEach((key, value) {
      list.add(Investment.fromMap(value, key));
    });
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
      'ownerUid': ownerUid,
      'ownerPhotoUrl': ownerPhotoUrl,
      'colorIndex': colorIndex,
      'imageURL': imageURL,
    };
  }
}
