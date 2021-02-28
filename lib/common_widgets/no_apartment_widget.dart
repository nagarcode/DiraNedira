import 'package:auto_size_text/auto_size_text.dart';
import 'package:dira_nedira/common_widgets/custom_raised_button.dart';
import 'package:dira_nedira/home/account/join_apartment_form.dart';
import 'package:dira_nedira/home/account/new_apartment_form.dart';
import 'package:flutter/material.dart';

import 'clipper.dart';

class NoApartmentWidget extends StatefulWidget {
  const NoApartmentWidget({
    Key key,
    @required this.mediaQuery,
  }) : super(key: key);

  final MediaQueryData mediaQuery;

  @override
  _NoApartmentWidgetState createState() => _NoApartmentWidgetState();
}

class _NoApartmentWidgetState extends State<NoApartmentWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
          color: Theme.of(context).primaryColor,
          child: ListView(
            children: [
              logo(),
              filledButton("הצטרף לדירה קיימת", Colors.blue, Colors.orange,
                  Colors.white, theme.primaryColor),
              outlineBtn(),
              weirdShape(),
            ],
          )),
    );
  }

  Widget logo() {
    return Center(
        child: Padding(
      padding: EdgeInsets.only(top: 120),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 240,
        child: Stack(
          children: <Widget>[
            Positioned(
                child: Container(
              child: Align(
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  width: 150,
                  height: 150,
                ),
                alignment: Alignment.center,
              ),
              height: 154,
            )),
            Positioned(
              child: Container(
                  height: 154,
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "דירה\n נדירה",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )),
            ),
            Positioned(
              width: 60,
              height: 60,
              top: 140,
              left: 260,
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
            ),
            Positioned(
              width: 30,
              height: 30,
              top: 200,
              left: 230,
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget filledButton(String text, Color splashColor, Color highlightColor,
      Color fillColor, Color textColor) {
    return RaisedButton(
      highlightElevation: 0.0,
      splashColor: splashColor,
      highlightColor: highlightColor,
      elevation: 0.0,
      color: fillColor,
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.bold, color: textColor, fontSize: 20),
      ),
      onPressed: () {
        JoinApartmentForm.show(context);
      },
    );
  }

  Widget outlineBtn() {
    return OutlineButton(
      highlightedBorderColor: Colors.white,
      borderSide: BorderSide(color: Colors.white, width: 2.0),
      highlightElevation: 0.0,
      splashColor: Colors.white,
      highlightColor: Theme.of(context).primaryColor,
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(30.0),
      ),
      child: Text(
        "צור דירה חדשה",
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
      ),
      onPressed: () {
        NewApartmentForm.show(context);
      },
    );
  }

  Widget weirdShape() {
    return Align(
      child: ClipPath(
        child: Container(
          color: Colors.white,
          height: 300,
        ),
        clipper: BottomWaveClipper(),
      ),
      alignment: Alignment.bottomCenter,
    );
  }
}
