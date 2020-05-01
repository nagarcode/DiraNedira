import 'package:flutter/foundation.dart';

class ShoppingItem {
  String title;
  bool checked;
  String authorPhotoUrl;
  String id;

  ShoppingItem(
      {@required this.title,
      @required this.checked,
      @required this.authorPhotoUrl,
      @required this.id});

  factory ShoppingItem.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) return null;
    final String title = data['title'];
    final bool checked = data['checked'];
    final String authorPhotoUrl = data['authorPhotoUrl'];
    return ShoppingItem(
        authorPhotoUrl: authorPhotoUrl,
        id: documentId,
        checked: checked,
        title: title);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'checked': checked,
      'authorPhotoUrl': authorPhotoUrl,
      'id': id,
    };
  }
}
