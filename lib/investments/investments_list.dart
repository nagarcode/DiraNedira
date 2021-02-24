import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/avatar.dart';
import 'package:dira_nedira/common_widgets/platform_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:dira_nedira/investments/new_investment_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InvestmentsList extends StatelessWidget {
  final List<Investment> investments;
  final bool isHistory;
  final int selectedColorIndex;
  InvestmentsList({this.investments, this.isHistory, this.selectedColorIndex});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final apartment = Provider.of<Apartment>(context, listen: false);
    final currentUser = Provider.of<DiraUser>(context, listen: false);
    final theme = Theme.of(context);
    final itemsToDisplay =
        selectedColorIndex != 2 ? _filterInestments() : investments;

    // final Brightness brightnessValue =
    //     MediaQuery.of(context).platformBrightness;

    if (apartment != null)
      return investments.isEmpty
          ? ListView(
              children: <Widget>[
                Center(
                  child: Text(
                    'לחץ על ה+ הלבן כדי להוסיף הוצאות, אנו נחשב עבור כל דייר מה מאזנו.',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Container(
                      height: 200,
                      child: Image.asset('assets/images/waiting.png',
                          fit: BoxFit.cover)),
                ),
              ],
            )
          : ListView.separated(
              separatorBuilder: (context, index) => Divider(
                  color:
                      // brightnessValue == Brightness.light
                      //     ?
                      Colors.grey
                  // : Colors.white70,
                  ),
              itemBuilder: (ctx, index) {
                debugPrint(
                    "index: " + investments[index].colorIndex.toString());
                print("title: " + investments[index].title);
                return ListTile(
                  // tileColor: Investment.colors.keys
                  //     .toList()[investments[index].colorIndex],
                  onTap: _isCurrentUserOwner(itemsToDisplay[index], currentUser)
                      ? () => _editInvestment(itemsToDisplay[index], context)
                      : null,
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: isHistory
                        ? theme.disabledColor
                        // : theme.appBarTheme.color,
                        : Investment.colors.keys
                            .toList()[itemsToDisplay[index].colorIndex],
                    radius: 25,
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: FittedBox(
                          child: Text(
                        '₪${itemsToDisplay[index].amount}',
                        style: TextStyle(
                            color: isHistory ? Colors.white : Colors.black),
                      )),
                    ),
                  ),
                  title: Text(
                    itemsToDisplay[index].title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: Text(
                      DateFormat.yMMMd().format(itemsToDisplay[index].date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Avatar(
                        photoUrl: itemsToDisplay[index].ownerPhotoUrl,
                        radius: 10,
                      ),
                      IconButton(
                        disabledColor: Colors.grey,
                        icon: Icon(
                          Icons.delete,
                        ),
                        color: Theme.of(context).errorColor,
                        onPressed: isDeletable(itemsToDisplay[index].ownerUid,
                                currentUser.uid, context)
                            ? () => _confirmDeleteInvestment(context,
                                itemsToDisplay, index, apartment.id, database)
                            : null,
                      ),
                    ],
                  ),
                );
              },
              itemCount: itemsToDisplay.length,
            );

    return Center(child: CircularProgressIndicator());
  }

  List<Investment> _filterInestments() {
    return investments.where((inv) {
      if ((inv.colorIndex == selectedColorIndex))
        return true;
      else
        return false;
    }).toList();
  }

  // int _countListItemsToDisplay() {
  //   return investments.fold(0, (previousValue, inv) {
  //     if (inv.colorIndex == selectedColorIndex || selectedColorIndex == 2)
  //       return previousValue + 1;
  //     else
  //       return previousValue;
  //   });
  // }

  bool isDeletable(String ownerId, String currentUserId, BuildContext context) {
    if (ownerId == currentUserId) return true;
    final userList = Provider.of<List<DiraUser>>(context, listen: false);
    bool found = false;
    for (int i = 0; i < userList.length; i++)
      if (userList[i].uid == ownerId) found = true;
    return !found;
  }

  Future<void> _confirmDeleteInvestment(
      BuildContext context,
      List<Investment> investments,
      int index,
      String apartmentId,
      Database database) async {
    final didRequestLeave = await PlatformAlertDialog(
      title: 'מחק הוצאה',
      content: 'האם אתה בטוח שברצונך למחוק הוצאה זו?',
      defaultActionText: 'מחק',
      cancelActionText: 'בטל',
    ).show(context);
    if (didRequestLeave) {
      database.deleteInvestment(investments[index], apartmentId);
    }
  }

  _isCurrentUserOwner(Investment investment, DiraUser currentUser) {
    return investment.ownerUid == currentUser.uid;
  }

  _editInvestment(Investment investment, BuildContext context) async {
    await NewInvestmentForm.show(context, investment: investment);
  }
}
