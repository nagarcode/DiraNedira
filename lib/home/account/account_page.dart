import 'package:auto_size_text/auto_size_text.dart';
import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/avatar.dart';
import 'package:dira_nedira/common_widgets/custom_raised_button.dart';
import 'package:dira_nedira/common_widgets/no_apartment_widget.dart';
import 'package:dira_nedira/common_widgets/platform_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/home/account/shopping_item.dart';
import 'package:dira_nedira/home/account/shopping_list.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class AccountPage extends StatefulWidget {
  AccountPage(this.database, this.apartmentId);
  final String apartmentId;
  final Database database;
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Stream<List<ShoppingItem>> shoppingItemsStream;

  @override
  void initState() {
    super.initState();
    shoppingItemsStream = getShoppingItemList();
  }

  Stream<List<ShoppingItem>> getShoppingItemList() {
    return widget.database.singleDocShoppingItemStream(widget.apartmentId);
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
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
    return PlatformAlertDialog(
      title: apartment.id,
      content: 'הסיסמא שלכם: ' + apartment.password,
      defaultActionText: 'סגור',
    ).show(context);
  }

  _leaveApartmentFlatButton(
      Apartment apartment, BuildContext context, Database database) {
    if (apartment == null)
      return Container();
    else
      return IconButton(
        icon: Icon(Icons.cancel_outlined, color: Colors.red),
        onPressed: () =>
            _confirmLeaveApartment(context, apartment.id, database),
      );
  }

  bool _isCurrentUser(DiraUser userToCheck, DiraUser currentUser) {
    return userToCheck.uid == currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final user = Provider.of<DiraUser>(context, listen: false);
    // we dont call auth.currentuser() because we can get the user SYNCHRONOUSLY here
    final mediaQuery = MediaQuery.of(context);
    final apartment = Provider.of<Apartment>(context, listen: false);
    // final theme = Theme.of(context);
    final userList = Provider.of<List<DiraUser>>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('דירה'),
        // leading: _leaveApartmentFlatButton(apartment, context, database),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              'התנתק',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onPressed: () => _confirmSignOut(context),
          )
        ],
      ),
      body: (apartment != null)
          ? SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child:
                        _apartmentCard(context, apartment, database, userList),
                  ),
                  Divider(),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: StreamBuilder<List<ShoppingItem>>(
                        stream: shoppingItemsStream,
                        builder: (context, snapshot) {
                          final shoppingList =
                              snapshot.hasData ? snapshot.data : null;
                          if (snapshot.connectionState !=
                                  ConnectionState.active &&
                              snapshot.connectionState != ConnectionState.done)
                            return CupertinoActivityIndicator();
                          else
                            return ShoppingList(
                                shoppingList, apartment, database, user);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          : NoApartmentWidget(
              mediaQuery: mediaQuery,
            ),
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
      Database database, List<DiraUser> userList) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            apartmentInfoCard(theme, apartment, context, database),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _userRowChildren(userList, apartment, database),
                // userList.map((data) {
                //   return _buildUserInfo(data, Colors.black, 25);
                // }).toList(),
              ),
            ),
            // SizedBox(height: 1),
            // leaveApartmentButton(context, apartment, database),
            // SizedBox(height: 1),
          ],
        ),
      ),
    );
  }

  _userRowChildren(
      List<DiraUser> userList, Apartment apartment, Database database) {
    final list = userList.map((data) {
      return _buildUserInfo(data, Colors.grey, 25);
    }).toList();
    list.insert(0, inviteUserWidget());
    return list;
  }

  Widget inviteUserWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54, width: 3.0)),
          child: InkWell(
            onTap: inviteUserToApartment,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black12,
              //backgroundImage: IconButton(icon: Icons.add,),
              child: Icon(
                Icons.add,
                size: 30,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        Center(
          child: AutoSizeText(
            '(הזמן לדירה)',
            style: TextStyle(color: Colors.lightBlue, fontSize: 13),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget apartmentInfoCard(ThemeData theme, Apartment apartment,
      BuildContext context, Database database) {
    return Container(
      width: double.infinity,
      child: Center(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Text(
            //   "הדירה הנדירה שלך:",
            //   style: theme.textTheme.subtitle2,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    apartment.id,
                    style: theme.textTheme.headline6,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child: Container(
                      margin: EdgeInsets.all(3),
                      child: Text(
                        'הצג סיסמא',
                        style: theme.textTheme.bodyText1,
                      )),
                  onTap: () => _showApartmentPassword(context, apartment),
                ),
                // _leaveApartmentFlatButton(apartment, context, database)
              ],
            )
          ],
        )),
      ),
    );
  }

  Widget _buildUserInfo(DiraUser user, Color color, double radius) {
    final database = Provider.of<Database>(context, listen: false);
    final currentUser = Provider.of<DiraUser>(context, listen: false);
    final apartment = Provider.of<Apartment>(context, listen: false);
    return Container(
      width: 80,
      height: 80,
      child: Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: Avatar(
                photoUrl: user.photoUrl,
                radius: radius,
              ),
            ),
            // SizedBox(height: 2),
            _userNameText(user, color),
            // SizedBox(height: 2),
          ],
        ),
        _isCurrentUser(user, currentUser)
            ? Align(
                child: _leaveApartmentFlatButton(apartment, context, database),
                alignment: Alignment.bottomRight,
              )
            : Container()
      ]),
    );
  }

  _userNameText(DiraUser user, Color color) {
    return Center(
      child: AutoSizeText(
        (user.disaplayName == null
            ? 'אנונימי'
            : user.disaplayName.split(' ').first),
        maxLines: 2,
        textAlign: TextAlign.center,
        style: TextStyle(color: color),
      ),
    );
  }

  inviteUserToApartment() async {
    final toShare = await _createDynamicLink();
    try {
      Share.share(toShare);
    } catch (e) {
      print(e);
    }
  }

  Future<String> _createDynamicLink() async {
    final apartment = Provider.of<Apartment>(context, listen: false);
    final id = apartment.id;
    final pass = apartment.password;
    final params = DynamicLinkParameters(
        uriPrefix: 'https://diranedira.page.link',
        link: Uri.parse('https://diranedira/inv?apt=$id&pass=$pass'),
        iosParameters: IosParameters(
            bundleId: 'com.NagarCode.diraNedira', appStoreId: '1508772635'));
    final shortLink = await params.buildShortLink();
    final shortUrl = shortLink.shortUrl;
    return 'קיבלת הזמנה לדירה שלי: \n' + shortUrl.toString();
  }
}
