import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/home/account/account_page.dart';
import 'package:dira_nedira/home/cupertino_home_scaffold.dart';
import 'package:dira_nedira/home/tab_item.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:dira_nedira/investments/investments_page.dart';
import 'package:dira_nedira/months/months_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage(this.database, this.apartmentId);
  Database database;
  String apartmentId;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.investments;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.months: GlobalKey<NavigatorState>(),
    TabItem.investments: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.months: (_) => MonthsPage(widget.database, widget.apartmentId),
      TabItem.investments: (_) => InvestmentsPage(
          isHistory: false,
          investments: Provider.of<List<Investment>>(context)),
      TabItem.account: (_) => AccountPage(),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      //pop to first route
      navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoHomeScaffold(
      currentTab: _currentTab,
      onSelectTab: _select,
      widgetBuilders: widgetBuilders,
      navigatorKeys: navigatorKeys,
    );
  }
}
