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
  @override
  Widget build(BuildContext context) {
    final apartment = Provider.of<Apartment>(context);
    final PreferredSizeWidget appBar = AppBar(
      title: Text('Investments'),
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
              child: monthsList(context), //TODO:Make scrollable
            ),
          ],
        ),
      );
    } else {
      return NoApartmentWidget(mediaQuery: mediaQuery);
    }
  }

  ListView monthsList(BuildContext context) {
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
