import 'package:dira_nedira/common_widgets/custom_raised_button.dart';
import 'package:dira_nedira/home/account/join_apartment_form.dart';
import 'package:dira_nedira/home/account/new_apartment_form.dart';
import 'package:flutter/material.dart';

class NoApartmentWidget extends StatelessWidget {
  const NoApartmentWidget({
    Key key,
    @required this.mediaQuery,
  }) : super(key: key);

  final MediaQueryData mediaQuery;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          alignment: Alignment.center,
          height: (mediaQuery.size.height - mediaQuery.padding.top) * 0.4,
          child: Card(
            elevation: 6,
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    "You do not have an apartment yet",
                  ),
                ),
                CustomRaisedButton(
                  child: Text(
                    'create apartment',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => NewApartmentForm.show(context),
                ),
                CustomRaisedButton(
                  child: Text(
                    'Join an existing apartment',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => JoinApartmentForm.show(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}