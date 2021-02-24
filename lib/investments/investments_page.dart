import 'package:auto_size_text/auto_size_text.dart';
import 'package:dira_nedira/common_widgets/no_apartment_widget.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/chart.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:dira_nedira/investments/investments_list.dart';
import 'package:dira_nedira/investments/new_investment_form.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class InvestmentsPage extends StatefulWidget {
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
  _InvestmentsPageState createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  final colors = Investment.colors.keys.toList();
  int _selectedColorIndex = 2;
  Container monthlyExpensesContainer(List<Investment> investments) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.grey[100],
          borderRadius: BorderRadius.all(Radius.circular(10))),
      width: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AutoSizeText(
            'הוצאות דירה החודש:',
            style: TextStyle(color: Colors.lightBlue),
          ),
          AutoSizeText(
            '₪' + _monthlySpendings(investments).toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ],
      ),
    );
  }

  _selectColor(int index) {
    setState(() {
      _selectedColorIndex = index;
    });
  }

  _colorText() {
    final theme = Theme.of(context);
    final colorMap = Investment.colors;
    return Text('\n' + colorMap.values.toList()[_selectedColorIndex],
        style: theme.textTheme.caption.copyWith(fontSize: 13));
  }

  _colorPicker() {
    final children = <Widget>[];
    children.add(Spacer(flex: 1));
    for (int i = 0; i < colors.length; i++) {
      children.add(
        Flexible(
          flex: 6,
          child: GestureDetector(
            onTap: () => _selectColor(i),
            child: Container(
              decoration: BoxDecoration(
                  color: colors[i],
                  border: Border.all(
                      color: _selectedColorIndex == i
                          ? Colors.lightBlue
                          : Colors.black54)),
              height: 20,
              width: 20,
            ),
          ),
        ),
      );
      if (i < 4) children.add(Spacer(flex: 1));
    }
    children.add(Spacer(flex: 1));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  _intermidiateColumn(List<Investment> investments) {
    return Column(children: [
      monthlyExpensesContainer(investments),
      SizedBox(height: 10),
      Stack(children: [
        Container(child: _colorPicker()),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: _colorText(),
        // )
        Row(
          children: [SizedBox(width: 10), _colorText()],
        )
      ]),

      // Expanded(child: Container()),
    ]);
  }

  int _monthlySpendings(List<Investment> investments) {
    var sum = 0;
    final monthToCalculate = DateTime.now().month;
    for (Investment inv in investments) {
      if (!widget.isHistory) {
        if (inv.date.month == monthToCalculate) sum += inv.amount;
      } else
        sum += inv.amount;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final apartment = Provider.of<Apartment>(context, listen: false);
    final theme = Theme.of(context);
    final PreferredSizeWidget appBar = AppBar(
      backgroundColor:
          widget.isHistory ? theme.disabledColor : theme.appBarTheme.color,
      title: Text('הוצאות'),
      actions: <Widget>[
        widget.isHistory
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
      backgroundColor: widget.isHistory ? Colors.grey[300] : Colors.white,
      appBar: appBar,
      body: _buildContents(context, appBar.preferredSize, widget.monthYear),
    );
  }

  Widget _buildContents(
      BuildContext context, Size appBarPrefsize, String monthYear) {
    final mediaQuery = MediaQuery.of(context);
    // final theme = Theme.of(context);
    final apartment = Provider.of<Apartment>(context, listen: false);
    final allInvestments = Provider.of<List<Investment>>(context);
    final investmentsToDisplay =
        filterInvestmentsList(allInvestments, monthYear);
    if (investmentsToDisplay != null)
      investmentsToDisplay.sort((a, b) => b.date.compareTo(a.date));
    // final currentMonthYear = DateFormat.yMMM().format(DateTime.now());
    if (apartment != null && investmentsToDisplay != null) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Expanded(
            //     flex: 1,
            //     child: _DateTitle(
            //         currentMonthYear: currentMonthYear, theme: theme)),
            Chart(
                investments: investmentsToDisplay, isHistory: widget.isHistory),
            _intermidiateColumn(investmentsToDisplay),
            Divider(
              color: Colors.grey,
            ),
            Expanded(
                flex: 15,
                child: InvestmentsList(
                  investments: investmentsToDisplay,
                  isHistory: widget.isHistory,
                  selectedColorIndex: _selectedColorIndex,
                )),
          ],
        ),
      );
    } else
      return NoApartmentWidget(mediaQuery: mediaQuery);
  }

  List<Investment> filterInvestmentsList(
      List<Investment> allInvestments, String monthYear) {
    if (monthYear == null) {
      return allInvestments;
    }
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
