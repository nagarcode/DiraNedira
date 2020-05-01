import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/avatar.dart';
import 'package:dira_nedira/common_widgets/custom_raised_button.dart';
import 'package:dira_nedira/common_widgets/no_apartment_widget.dart';
import 'package:dira_nedira/common_widgets/platform_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await PlatformAlertDialog(
      title: 'התנתק',
      content: 'האם אתה בטוח שברצונך להתנתק?',
      defaultActionText: 'התנתק',
      cancelActionText: 'ביטול',
    ).show(context);
    if (didRequestSignOut) {
      _signOut(context);
    }
  }

  Future<void> _confirmLeaveApartment(
      BuildContext context, String apartmentId, Database database) async {
    final didRequestLeave = await PlatformAlertDialog(
      title: 'עזוב דירה',
      content: 'האם אתה בטוח שברצונך לעזוב את הדירה שלך?',
      defaultActionText: 'עזוב',
      cancelActionText: 'ביטול',
    ).show(context);
    if (didRequestLeave) {
      _leaveApartment(apartmentId, database);
    }
  }

  Future<void> _leaveApartment(String apartmentId, Database database) async {
    await database.leaveApartment(apartmentId);
  }

  Future<void> _showApartmentPassword(
      BuildContext context, Apartment apartment) {
    PlatformAlertDialog(
      title: apartment.id,
      content: 'הסיסמא שלכם: ' + apartment.password,
      defaultActionText: 'סגור',
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    print('building account page');
    final database = Provider.of<Database>(context);
    final user = Provider.of<User>(context);
    // we dont call auth.currentuser() because we can get the user SYNCHRONOUSLY here
    final mediaQuery = MediaQuery.of(context);
    final apartment = Provider.of<Apartment>(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('דירה'),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              'התנתק',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onPressed: () => _confirmSignOut(context),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: _buildUserInfo(user, Colors.white, 50),
        ),
      ),
      body: (apartment != null)
          ? SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _hasApartmentColumn(context, apartment, database),
                  Center(
                      child: Text(
                    'פיצ׳רים נוספים בקרוב!',
                    style: theme.textTheme.title,
                  )),
                  Center(
                      child: Text(
                    'הישארו מעודכנים, פונקציונליות נוספת בדרך בזמן הקרוב! \n' +
                        'האפליקציה ״דירה נדירה״ מפותחת ע״י סטודנט יחיד ולא חברת ענק, לכן אשמח לשמוע כל בעיה/בקשה/חוות דעת :) מייל: \n' +
                        'dira.nedira.team@gmail.com',
                    textAlign: TextAlign.center,
                  )),
                ],
              ),
            )
          : NoApartmentWidget(
              mediaQuery: mediaQuery,
            ),
    );
  }

  Widget _hasApartmentColumn(
      BuildContext context, Apartment apartment, Database database) {
    final userList = Provider.of<List<User>>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          child: _apartmentCard(context, apartment, database, userList),
        ),
      ],
    );
  }

  CustomRaisedButton leaveApartmentButton(
      BuildContext context, Apartment apartment, Database database) {
    return CustomRaisedButton(
      child: Text(
        'עזוב דירה',
        style: TextStyle(color: Colors.white),
      ),
      color: Colors.red,
      onPressed: () => _confirmLeaveApartment(context, apartment.id, database),
    );
  }

  Widget _apartmentCard(BuildContext context, Apartment apartment,
      Database database, List<User> userList) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
      elevation: 6,
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            apartmentInfoCard(theme, apartment, context),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: userList.map((data) {
                  return _buildUserInfo(data, Colors.black, 25);
                }).toList(),
              ),
            ),
            SizedBox(height: 1),
            leaveApartmentButton(context, apartment, database),
            // SizedBox(height: 1),
          ],
        ),
      ),
    );
  }

  Widget apartmentInfoCard(
      ThemeData theme, Apartment apartment, BuildContext context) {
    return Container(
      width: double.infinity,
      child: Center(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              "הדירה הנדירה שלך:",
              style: theme.textTheme.title.copyWith(color: theme.primaryColor),
            ),
            Center(
              child: Text(
                apartment.id,
                style: theme.textTheme.title,
              ),
            ),
            InkWell(
              child: Container(
                  margin: EdgeInsets.all(3),
                  child: Text(
                    'הצג סיסמא',
                    style: theme.textTheme.body2,
                  )),
              onTap: () => _showApartmentPassword(context, apartment),
            )
          ],
        )),
      ),
    );
  }

  Widget _buildUserInfo(User user, Color color, double radius) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Avatar(
          photoUrl: user.photoUrl,
          radius: radius,
        ),
        // SizedBox(height: 2),
        Text(
          '   ' +
              (user.disaplayName == null
                  ? 'אנונימי'
                  : user.disaplayName + '  '),
          style: TextStyle(color: color),
        ),
        // SizedBox(height: 2),
      ],
    );
  }
}
