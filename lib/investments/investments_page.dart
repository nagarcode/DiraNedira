import 'package:dira_nedira/common_widgets/no_apartment_widget.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/chart.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:dira_nedira/investments/investments_list.dart';
import 'package:dira_nedira/investments/new_investment_form.dart';
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
        child: Column(//TODO Add pie chart
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
    } else
      return NoApartmentWidget(mediaQuery: mediaQuery);
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
