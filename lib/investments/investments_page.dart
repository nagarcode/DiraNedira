import 'package:dira_nedira/common_widgets/no_apartment_widget.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/chart.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:dira_nedira/investments/investments_list.dart';
import 'package:dira_nedira/investments/new_investment_form.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class InvestmentsPage extends StatelessWidget {
  final bool isHistory;
  final List<Investment> investments;
  InvestmentsPage({this.isHistory, this.investments});

  static Future<void> show(
      {BuildContext context,
      bool isHistory,
      Future<List<Investment>> investmentsFuture}) async {
    final investmentsToDisplay = await investmentsFuture;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvestmentsPage(
          isHistory: isHistory,
          investments: investmentsToDisplay,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apartment = Provider.of<Apartment>(context);
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
                  style: Theme.of(context).textTheme.title.copyWith(
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
      body: _buildContents(context, appBar.preferredSize),
    );
  }

  Widget _buildContents(BuildContext context, Size appBarPrefsize) {
    final mediaQuery = MediaQuery.of(context);
    final apartment = Provider.of<Apartment>(context);
    final currentMonthInvestments = investments;
    final containerHeight = mediaQuery.size.height * 0.3;
    if (apartment != null && currentMonthInvestments != null) {
      return SafeArea(
        child: Column(
          //TODO Add pie chart
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Expanded(
            //   flex: 2,
              // child: Container(
              // child: 
              Chart(
                investments: currentMonthInvestments,
              ),
              // ),
            // ),
            Divider(
              color: Colors.grey,
            ),
            Expanded(
              flex: 3,
              child: 
              InvestmentsList(
                  investments: investments, isHistory: isHistory),
            ),
          ],
        ),
      );
    } else
      return NoApartmentWidget(mediaQuery: mediaQuery);
  }
}
