import 'package:flutter/material.dart';

enum TabItem { investments, months, account }

class TabItemData {
  const TabItemData({@required this.title, @required this.icon});
  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.investments:
        TabItemData(title: 'הוצאות', icon: Icons.view_list),
    TabItem.account: TabItemData(title: 'דירה', icon: Icons.person),
    TabItem.months: TabItemData(title: 'היסטוריה', icon: Icons.access_time),
  };
}
