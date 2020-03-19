import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/avatar.dart';
import 'package:dira_nedira/common_widgets/custom_raised_button.dart';
import 'package:dira_nedira/common_widgets/no_apartment_widget.dart';
import 'package:dira_nedira/common_widgets/platform_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
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
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      defaultActionText: 'Logout',
      cancelActionText: 'Cancel',
    ).show(context);
    if (didRequestSignOut) {
      _signOut(context);
    }
  }

  Future<void> _confirmLeaveApartment(
      BuildContext context, String apartmentId, Database database) async {
    final didRequestLeave = await PlatformAlertDialog(
      title: 'Leave Apartment',
      content: 'Are you sure that you want to leave your apartment?',
      defaultActionText: 'Leave',
      cancelActionText: 'Cancel',
    ).show(context);
    if (didRequestLeave) {
      _leaveApartment(apartmentId, database);
    }
  }

  Future<void> _leaveApartment(String apartmentId, Database database) async {
    await database.leaveApartment(apartmentId);
  }

  @override
  Widget build(BuildContext context) {
    print('building account page');
    final database = Provider.of<Database>(context);
    final user = Provider.of<User>(context);
    // we dont call auth.currentuser() because we can get the user SYNCHRONOUSLY here
    final mediaQuery = MediaQuery.of(context);
    final apartment = Provider.of<Apartment>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _hasApartmentColumn(context, apartment, database)
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
    final mediaQuery = MediaQuery.of(context);
    final userList = Provider.of<List<User>>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: (mediaQuery.size.height - mediaQuery.padding.top) * 0.3,
          child: _usersCard(context, apartment, database, userList),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomRaisedButton(
              child: Text(
                'Leave Apartment',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.red,
              onPressed: () =>
                  _confirmLeaveApartment(context, apartment.id, database),
            ),
          ],
        ),
      ],
    );
  }

  Widget _usersCard(BuildContext context, Apartment apartment,
      Database database, List<User> userList) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Center(
              child: Text("Your Dira Nedira:\n ${apartment.id}"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: userList.map((data) {
                return _buildUserInfo(data, Colors.black, 25);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(User user, Color color, double radius) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      direction: Axis.vertical,
      children: <Widget>[
        Avatar(
          photoUrl: user.photoUrl,
          radius: radius,
        ),
        SizedBox(height: 2),
        if (user.disaplayName != null)
          Text(
            user.disaplayName,
            style: TextStyle(color: color),
          ),
        SizedBox(height: 2),
      ],
    );
  }
}
