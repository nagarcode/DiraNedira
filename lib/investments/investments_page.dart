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
    final allInvestments = Provider.of<List<Investment>>(context);
    final investmentsToDisplay =
        filterInvestmentsList(allInvestments, monthYear);
    if (investmentsToDisplay != null)
      investmentsToDisplay.sort((a, b) => b.date.compareTo(a.date));
    final currentMonthYear = DateFormat.yMMM().format(DateTime.now());
    if (apartment != null && investmentsToDisplay != null) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: _DateTitle(
                    currentMonthYear: currentMonthYear, theme: theme)),
            Chart(investments: investmentsToDisplay, isHistory: isHistory),
            Divider(
              color: Colors.grey,
            ),
            Expanded(
                flex: 15,
                child: InvestmentsList(
                    investments: investmentsToDisplay, isHistory: isHistory)),
          ],
        ),
      );
    } else
      return NoApartmentWidget(mediaQuery: mediaQuery);
  }

  List<Investment> filterInvestmentsList(
      List<Investment> allInvestments, String monthYear) {
    if (monthYear == null) return allInvestments;
    final List<Investment> investmentsToDisplay = [];
    for (Investment inv in allInvestments) {
      final invMonthYear = DateFormat.yMMM().format(inv.date);
      if (invMonthYear == monthYear) investmentsToDisplay.add(inv);
    }
    return investmentsToDisplay;
  }
}

class _DateTitle extends StatelessWidget {
  const _DateTitle({
    Key key,
    @required this.currentMonthYear,
    @required this.theme,
  }) : super(key: key);

  final String currentMonthYear;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        currentMonthYear,
        style: theme.textTheme.headline6,
      ),
    );
  }
}
