import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/no_apartment_widget.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/investments_page.dart';
import 'package:dira_nedira/splash-screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthsPage extends StatefulWidget {
  MonthsPage(this.database, this.apartmentId);
  final String apartmentId;
  final Database database;
  @override
  _MonthsPageState createState() => _MonthsPageState();
}

class _MonthsPageState extends State<MonthsPage>
// with AutomaticKeepAliveClientMixin<MonthsPage>
{
  Future monthsFuture;

  @override
  void initState() {
    super.initState();
    monthsFuture = monthsSumMap();
  }

  Future<Map<String, dynamic>> monthsSumMap() async {
    return await widget.database.getMonthlySumDoc(widget.apartmentId);
  }

  // @override
  // bool get wantKeepAlive => true;

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
    final apartment = Provider.of<Apartment>(context);
    if (apartment != null) {
      // theme.textTheme.
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
                    future: monthsFuture,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return SplashScreen();
                        case ConnectionState.active:
                          return SplashScreen();
                        case ConnectionState.waiting:
                          return SplashScreen();
                        case ConnectionState.done:
                          final listToDisplay =
                              monthsList(context, snapshot.data);
                          if (listToDisplay == null) {
                            return Center(
                              child: Text(
                                'טרם עבר חודש מאז שהתחלתם להשתמש ב״דירה נדירה״',
                                style: theme.textTheme.bodyText1,
                              ),
                            );
                          }
                          return listToDisplay;
                        default:
                          return SplashScreen();
                      }
                    })
                //TODO: limit the free version to 3 months history, paid - one year
                ),
          ],
        ),
      );
    } else {
      return NoApartmentWidget(mediaQuery: mediaQuery);
    }
  }

  ListView monthsList(BuildContext context,
      Map<String, dynamic> monthsWithTransactionsAndAmount) {
    final theme = Theme.of(context);
    final currentMonthYear = DateFormat.yMMM().format(DateTime.now());
    if (monthsWithTransactionsAndAmount == null ||
        monthsWithTransactionsAndAmount.length == 1) return null;
    final keys = monthsWithTransactionsAndAmount.keys.toList();
    keys.remove(currentMonthYear);
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
                investmentsFuture: widget.database.getInvestmentsByMonthYear(
                    keys[reversedIndex], widget.apartmentId));
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
                        monthsWithTransactionsAndAmount[keys[reversedIndex]]
                            .toString(),
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
}
