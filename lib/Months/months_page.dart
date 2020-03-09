import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/no_apartment_widget.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthsPage extends StatefulWidget {
  @override
  _MonthsPageState createState() => _MonthsPageState();
}

class _MonthsPageState extends State<MonthsPage> {
  Future monthsFuture;
  @override
  void initState() {
    super.initState();
    monthsFuture = _getMonthsWithTransactions();
  }

  _getMonthsWithTransactions() async {
    final List<String> months = List<String>();
    for (int i = 1; i < 12; i++) {
      months.add(DateFormat.yMMM()
          .format(DateTime.now().subtract(Duration(days: 31 * (i)))));
    }
    final database = Provider.of<Database>(context);
    return await database.getMonthsWithTransactions(
        Provider.of<Apartment>(context).id, months);
  }

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = AppBar(
      title: Text('History'),
    );
    return Scaffold(
      appBar: appBar,
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final apartment = Provider.of<Apartment>(context);

    if (apartment != null) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
                    future: monthsFuture,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Text('Connection status: none');
                        case ConnectionState.active:
                          return Text('Connection status: active');
                        case ConnectionState.waiting:
                          return Text('Connection status: waiting');
                        case ConnectionState.done:
                          return monthsList(context, snapshot.data);
                      }
                    })
                //monthsList(context), //TODO:Make scrollable
                //TODO: limit the free version to 3 months history, paid - one year
                ),
          ],
        ),
      );
    } else {
      return NoApartmentWidget(mediaQuery: mediaQuery);
    }
  }

  ListView monthsList(
      BuildContext context, List<String> monthsWithTransactions) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          elevation: 5,
          child: ListTile(
            title: Center(
              child: Text(
                DateFormat.yMMM().format(
                    DateTime.now().subtract(Duration(days: 31 * (index + 1)))),
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(color: Colors.lightBlue),
              ),
            ),
            //subtitle: Text(DateFormat.yMMMd().format(investments[index].date)),
          ),
        );
      },
      itemCount: 12,
    );
  }
}
