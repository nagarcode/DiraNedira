import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonthsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
        final apartment = Provider.of<Apartment>(context);
    return Container(
      child: Center(
        child: apartment != null ? Text(
          Provider.of<List<User>>(context).last.disaplayName,
        ) : Text('lolz'),
      ),
    );
  }
}
