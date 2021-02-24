import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AdaptiveFlatButton extends StatelessWidget {
  final String text;
  final Function handler;
  Color color;

  AdaptiveFlatButton({this.text, this.handler, Color color}) {
    if (color != null) this.color = color;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Platform.isIOS
        ? CupertinoButton(
            child: Text(text,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            onPressed: handler,
          )
        : FlatButton(
            textColor: Theme.of(context).primaryColor,
            child: Text(text,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            onPressed: handler,
          );
  }
}
