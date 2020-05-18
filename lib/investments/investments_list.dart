import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/avatar.dart';
import 'package:dira_nedira/common_widgets/platform_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InvestmentsList extends StatelessWidget {
  final List<Investment> investments;
  final bool isHistory;
  InvestmentsList({this.investments, this.isHistory});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final apartment = Provider.of<Apartment>(context, listen: false);
    final currentUser = Provider.of<User>(context, listen: false);
    final theme = Theme.of(context);
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;

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
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: isHistory
                        ? theme.disabledColor
                        : theme.appBarTheme.color,
                    radius: 25,
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: FittedBox(
                          child: Text(
                        '₪${investments[index].amount}',
                        style: TextStyle(
                            color: isHistory ? Colors.white : Colors.black),
                      )),
                    ),
                  ),
                  title: Text(
                    investments[index].title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle:
                      Text(DateFormat.yMMMd().format(investments[index].date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Avatar(
                        photoUrl: investments[index].ownerPhotoUrl,
                        radius: 10,
                      ),
                      IconButton(
                        disabledColor: Colors.grey,
                        icon: Icon(
                          Icons.delete,
                        ),
                        color: Theme.of(context).errorColor,
                        onPressed: isDeletable(investments[index].ownerUid,
                                currentUser.uid, context)
                            ? () => _confirmDeleteInvestment(context,
                                investments, index, apartment.id, database)
                            : null,
                      ),
                    ],
                  ),
                );
              },
              itemCount: investments.length,
            );

    return Center(child: CircularProgressIndicator());
  }

  bool isDeletable(String ownerId, String currentUserId, BuildContext context) {
    if (ownerId == currentUserId) return true;
    final userList = Provider.of<List<User>>(context, listen: false);
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
}
