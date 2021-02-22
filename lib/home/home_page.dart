import 'package:dira_nedira/Months/months_page.dart';
import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/platform_alert_dialog.dart';
import 'package:dira_nedira/home/account/account_page.dart';
import 'package:dira_nedira/home/cupertino_home_scaffold.dart';
import 'package:dira_nedira/home/tab_item.dart';
import 'package:dira_nedira/investments/investments_page.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage(this.database, this.apartmentId);
  final Database database;
  final String apartmentId;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    super.initState();
    initDynamicLinks();
  }

  void initDynamicLinks() async {
    await Future.delayed(Duration(seconds: 3));
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    final deepLink = data?.link;
    if (deepLink != null) {
      final queryParams = deepLink.queryParameters;
      if (queryParams.length > 0) {
        final id = queryParams['apt'];
        final pass = queryParams['pass'];
        _handleAptInvite(id, pass);
      }
    }
    FirebaseDynamicLinks.instance.onLink(onSuccess: (dynamicLink) async {
      final deepLink = dynamicLink?.link;
      if (deepLink != null) {
        final queryParams = deepLink.queryParameters;
        if (queryParams.length > 0) {
          final id = queryParams['apt'];
          final pass = queryParams['pass'];
          _handleAptInvite(id, pass);
        }
      }
    }, onError: (e) async {
      debugPrint('DynamicLinks onError $e');
    });
  }

  _handleAptInvite(String newAptId, String pass) async {
    final user = Provider.of<DiraUser>(context, listen: false);

    final hasApartment = widget.apartmentId != null;
    if (hasApartment) {
      bool wantsToChangeApt = await _queryWantsToChangeApt(newAptId);
      if (wantsToChangeApt) {
        await widget.database.leaveApartment(widget.apartmentId);
        _joinNewApt(newAptId, pass, user);
      }
    } else {
      await _showWelcomeDialogue();
      _joinNewApt(newAptId, pass, user);
    }
  }

  _joinNewApt(String newAptId, String pass, DiraUser user) async {
    await widget.database.loginToApartment(apartmentId: newAptId, pass: pass);

    await widget.database.setUserApartment(newAptId);
    await widget.database
        .addUserDataToApartment(apartmentId: newAptId, data: user.dataMap());
  }

  _showWelcomeDialogue() {
    final dialogue = PlatformAlertDialog(
        content:
            'ברוכים הבאים ל״דירה נדירה״! הגעת דרך קישור ישיר לדירה זו, אם ברצונך ליצור דירה משלך תוכל לעזוב דירה זו בעמוד ״דירה״',
        defaultActionText: 'סגור',
        title: 'ברוכים הבאים!');
    dialogue.show(context);
  }

  Future<bool> _queryWantsToChangeApt(String newAptId) async {
    final dialogue = PlatformAlertDialog(
      content:
          'קיבלת הזמנה לדירה: $newAptId. האם ברצונך לעזוב את הדירה הנוכחית ולהצטרף ל$newAptId?',
      defaultActionText: 'החלף דירה',
      title: 'שינוי דירה',
      cancelActionText: 'בטל',
    );
    final wantsToChangeApt = await dialogue.show(context);
    return wantsToChangeApt;
  }

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
            monthYear: null,
          ),
      TabItem.account: (_) => AccountPage(widget.database, widget.apartmentId),
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
