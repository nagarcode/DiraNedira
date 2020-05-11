import 'package:dira_nedira/common_widgets/no_apartment_widget.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/chart.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:dira_nedira/investments/investments_list.dart';
import 'package:dira_nedira/investments/new_investment_form.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class InvestmentsPage extends StatelessWidget {
  final bool isHistory;
  final String monthYear;
  InvestmentsPage({this.isHistory, this.monthYear});

  static Future<void> show(
      {BuildContext context, bool isHistory, String monthYear}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvestmentsPage(
          isHistory: isHistory,
          monthYear: monthYear,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apartment = Provider.of<Apartment>(context, listen: false);
    final theme = Theme.of(context);
    final PreferredSizeWidget appBar = AppBar(
      backgroundColor:
          isHistory ? theme.disabledColor : theme.appBarTheme.color,
      title: Text('הוצאות'),
      actions: <Widget>[
        isHistory
            ? FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'סיום',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.white, fontWeight: FontWeight.normal),
                ),
              )
            : IconButton(
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
      backgroundColor: isHistory ? Colors.grey[300] : Colors.white,
      appBar: appBar,
      body: _buildContents(context, appBar.preferredSize, monthYear),
    );
  }

  Widget _buildContents(
      BuildContext context, Size appBarPrefsize, String monthYear) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final apartment = Provider.of<Apartment>(context, listen: false);
    final investmentsToDisplay = Provider.of<List<Investment>>(context);
    if (monthYear != null)
      filterInvestmentsList(investmentsToDisplay, monthYear);
    if (investmentsToDisplay != null)
      investmentsToDisplay.sort((a, b) => b.date.compareTo(a.date));
    final currentMonthYear = DateFormat.yMMM().format(DateTime.now());
    if (apartment != null && investmentsToDisplay != null) {
      return SafeArea(
        child: Column(
          //TODO Add pie chart
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                currentMonthYear,
                style: theme.textTheme.headline6,
              ),
            ),
            // Expanded(
            //   flex: 2,
            // child: Container(
            // child:
            Chart(
              investments: investmentsToDisplay,
            ),
            // ),
            // ),
            Divider(
              color: Colors.grey,
            ),
            Expanded(
              flex: 3,
              child: InvestmentsList(
                  investments: investmentsToDisplay, isHistory: isHistory),
            ),
          ],
        ),
      );
    } else
      return NoApartmentWidget(mediaQuery: mediaQuery);
  }

  filterInvestmentsList(
      List<Investment> investmentsToDisplay, String monthYear) {
    for (Investment inv in investmentsToDisplay) {
      final invMonthYear = DateFormat.yMMM().format(inv.date);
      if (invMonthYear != monthYear) investmentsToDisplay.remove(inv);
    }
  }
}
