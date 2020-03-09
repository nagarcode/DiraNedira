import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/home/account/account_page.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/home/cupertino_home_scaffold.dart';
import 'package:dira_nedira/home/tab_item.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:dira_nedira/investments/investments_page.dart';
import 'package:dira_nedira/months/months_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
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
      TabItem.months: (_) => MonthsPage(),
      TabItem.investments: (_) => InvestmentsPage(),
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
    final database = Provider.of<Database>(context);
    return StreamBuilder<String>(
      stream: database.apartmentIdStream(),
      builder: (context, snapshot) {
        final apartmentId = snapshot.hasData ? snapshot.data : null;
        return StreamBuilder<Apartment>(
          stream: database.apartmentStream(apartmentId),
          builder: (context, apartmentSnapshot) {
            final apartment = apartmentSnapshot.hasData && apartmentId != null
                ? apartmentSnapshot.data
                : null;
            return StreamBuilder<List<User>>(
              stream: database.userStream(apartmentId),
              builder: (context, usersSnapshot) {
                final usersList = usersSnapshot.hasData && apartmentId != null
                    ? usersSnapshot.data
                    : null;
                return StreamBuilder<List<Investment>>(
                  stream: apartment == null
                      ? Stream.empty()
                      : database.investmentsStream(apartment.id,
                          DateFormat.yMMM().format(DateTime.now())),
                  builder: (context, investmentsSnapshot) {
                    final apartmentInvestments = investmentsSnapshot.hasData
                        ? investmentsSnapshot.data
                        : null;
                    if (apartmentInvestments != null)
                      apartmentInvestments
                          .sort((a, b) => b.date.compareTo(a.date));
                    return Provider<Apartment>.value(
                      value: apartment,
                      child: Provider<List<Investment>>.value(
                        value: apartmentInvestments,
                        child: Provider<List<User>>.value(
                          value: usersList,
                          child: WillPopScope(
                            onWillPop: () async =>
                                !await navigatorKeys[_currentTab]
                                    .currentState
                                    .maybePop(),
                            child: CupertinoHomeScaffold(
                              currentTab: _currentTab,
                              onSelectTab: _select,
                              widgetBuilders: widgetBuilders,
                              navigatorKeys: navigatorKeys,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
