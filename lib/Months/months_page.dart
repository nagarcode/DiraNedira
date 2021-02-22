import 'package:auto_size_text/auto_size_text.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/no_apartment_widget.dart';
import 'package:dira_nedira/common_widgets/spendings_chart.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:dira_nedira/investments/investments_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthsPage extends StatelessWidget {
  MonthsPage(this.database, this.apartmentId);
  final String apartmentId;
  final Database database;

  final Map<String, List<Investment>> monthsToInvestments = {};

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = AppBar(
      title: const Text('היסטוריה'),
    );
    return Scaffold(
      appBar: appBar,
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final apartment = Provider.of<Apartment>(context, listen: false);
    final listToDisplay = monthsToInvestments;
    final investments = Provider.of<List<Investment>>(context);
    if (apartment != null) initMonthsPage(investments);
    if (apartment != null) {
      // theme.textTheme.
      return SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: listToDisplay == null || listToDisplay.isEmpty
                    ? Center(
                        child: Text('טרם בוצעו תשלומים',
                            style: theme.textTheme.bodyText1),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              // flex: 50,
                              child: monthsList(context, listToDisplay)),
                          // Flexible(
                          // flex: 5,
                          // child:
                          // Divider(),
                          totalInvestments(context, investments)
                          // )
                          ,
                        ],
                      )

                //TODO: limit the free version to 3 months history, paid - one year
                ),
          ],
        ),
      );
    } else {
      return NoApartmentWidget(mediaQuery: mediaQuery);
    }
  }

  _chartIcon(List<Investment> investments, BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.insert_chart_outlined,
        size: 30,
        // color: Colors.lightBlue[200],
      ),
      onPressed: () => SpendingsChart.show(context, investments),
    );
  }

  ListView monthsList(
      BuildContext context, Map<String, dynamic> monthsToInvestments) {
    final theme = Theme.of(context);
    // final currentMonthYear = DateFormat.yMMM().format(DateTime.now());
    // if (monthsToInvestments == null || monthsToInvestments.length == 1)
    //   return null;
    final keys = monthsToInvestments.keys.toList();
    // keys.remove(currentMonthYear);
    final length = keys.length;

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (ctx, index) {
        var reversedIndex = length - index - 1;
        return GestureDetector(
          onTap: () {
            InvestmentsPage.show(
                isHistory: true,
                context: context,
                monthYear: keys[reversedIndex]);
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
            elevation: 2,
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(keys[reversedIndex] + ':',
                      style: theme.textTheme.headline6),
                ],
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '₪' +
                        getMonthlySum(monthsToInvestments[keys[reversedIndex]]),
                    style: theme.textTheme.subtitle2,
                  ),
                  Text(
                    'סה״כ הוצאות דירה חודשיות',
                    style: theme.textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  totalInvestments(BuildContext context, List<Investment> investments) {
    return Center(
      child: Container(
        // decoration: BoxDecoration(border: Border.all(color: Colors.lightBlue)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chartIcon(investments, context),
            AutoSizeText(
              'הוצאות דירה כוללות:',
              style: TextStyle(color: Colors.lightBlue),
            ),
            AutoSizeText(
              '₪' + totalSpending(context).toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            // Transform.scale(
            //   scale: 0.5,
            //   child: _chartSwitch(context),
            // ),
            // Transform.scale(
            //     scale: 0.8, child: SpendingsChart(investments: investments))
          ],
        ),
      ),
    );
  }

  int totalSpending(BuildContext context) {
    final investments = Provider.of<List<Investment>>(context);
    var sum = 0;
    for (var i = 0; i < investments.length; i++) {
      sum += investments[i].amount;
    }
    return sum;
  }

  getInvestmentsByMonthYear(String monthYear) {
    return monthsToInvestments[monthYear];
  }

  getMonthlySum(List<Investment> investments) {
    var sum = 0;
    for (Investment inv in investments) sum += inv.amount;
    return sum.toString();
  }

  void initMonthsPage(List<Investment> allInvestments) {
    for (Investment inv in allInvestments) {
      final monthYear = DateFormat.yMMM().format(inv.date);
      if (!monthsToInvestments.containsKey(monthYear))
        monthsToInvestments[monthYear] = [];
      monthsToInvestments[monthYear].add(inv);
    }
  }

  // _chartSwitch(BuildContext context) {
  //   final theme = Theme.of(context);
  //   return CupertinoSwitch(
  //     value: true,
  //     onChanged: (newVal) {},
  //     activeColor: Colors.lightBlue[200],
  //   );
  // }
}
