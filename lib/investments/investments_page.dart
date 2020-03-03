import 'package:dira_nedira/common_widgets/custom_raised_button.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/home/account/join_apartment_form.dart';
import 'package:dira_nedira/home/account/new_apartment_form.dart';

import './chart.dart';
import '../investments/investments_list.dart';
import '../investments/new_investment_form.dart';
import './investment.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class InvestmentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final apartment = Provider.of<Apartment>(context);
    final PreferredSizeWidget appBar = AppBar(
      title: Text('Investments'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add, color: Colors.white),
          onPressed: () {
            if (apartment != null)
              return NewInvestmentForm.show(context);
            else
              return null;
          },
        ),
      ],
    );
    return Scaffold(
      appBar: appBar,
      body: _buildContents(context, appBar.preferredSize),
    );
  }

  Widget _buildContents(BuildContext context, Size appBarPrefsize) {
    final mediaQuery = MediaQuery.of(context);
    final apartment = Provider.of<Apartment>(context);
    final apartmentInvestments = Provider.of<List<Investment>>(
        context); //TODO: change to this month's investments
    if (apartment != null && apartmentInvestments != null) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 250,
              child: Chart(
                currentMonthInvestments(apartmentInvestments),
              ),
            ), 
            Expanded(
              child: InvestmentsList(), //TODO:Make scrollable
            ),
          ],
        ),
      );
    } else {
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

  List<Investment> currentMonthInvestments(
      List<Investment> apartmentInventments) {
    List<Investment> toReturn = new List();
    apartmentInventments.forEach((inv) {
      if (inv.date.month == DateTime.now().month) toReturn.add(inv);
    });
    return toReturn;
  }
}
