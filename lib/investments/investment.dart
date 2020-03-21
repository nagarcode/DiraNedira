import 'package:flutter/foundation.dart';

class Investment {
  String title;
  int amount;
  DateTime date;
  String id;
  String ownerUid;
  String ownerPhotoUrl;

  Investment({
    @required this.title,
    @required this.amount,
    @required this.date,
    @required this.id,
    @required this.ownerUid,
    @required this.ownerPhotoUrl,
  });

  factory Investment.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) return null;
    final String title = data['title'];
    final int amount = data['amount'];
    final DateTime date = data['date'].toDate();
    final String ownerUid = data['ownerUid'];
    final String ownerPhotoUrl = data['ownerPhotoUrl'];
    return Investment(
        amount: amount,
        title: title,
        date: date,
        id: documentId,
        ownerUid: ownerUid,
        ownerPhotoUrl: ownerPhotoUrl);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
      'ownerUid': ownerUid,
      'ownerPhotoUrl': ownerPhotoUrl,
    };
  }
}
