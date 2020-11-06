import 'package:auto_size_text/auto_size_text.dart';
import 'package:dira_nedira/common_widgets/avatar.dart';
import 'package:flutter/material.dart';

class UserAccountBar extends StatelessWidget {
  final String displayName;
  final String photoUrl;

  UserAccountBar({this.displayName, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(
          children: <Widget>[
            Container(
              height: constraints.maxHeight * 0.15,
              child: FittedBox(child: Text('$displayName')),
            ),
            SizedBox(
              height: constraints.maxHeight * 0.05,
            ),
            Container(
              height: constraints.maxHeight * 0.6,
              width: 10,
              child: Stack(
                children: <Widget>[
                  Avatar(
                    photoUrl: photoUrl,
                    radius: 50,
                  )
                ],
              ),
            ),
            SizedBox(
              height: constraints.maxHeight * 0.05,
            ),
            Container(
              height: constraints.maxHeight * 0.15,
              child: FittedBox(
                  child: AutoSizeText(
                displayName,
                maxLines: 2,
              )),
            ),
          ],
        );
      },
    );
  }
}
