import 'package:auto_size_text/auto_size_text.dart';
import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/common_widgets/avatar.dart';
import 'package:dira_nedira/common_widgets/spendings_chart.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class Chart extends StatelessWidget {
  final List<Investment> investments;
  final Map<String, int> userInvestmentSum = new Map();
  final bool isHistory;

  Chart({@required this.investments, @required this.isHistory});

  int get monthlySpendings {
    var sum = 0;
    final monthToCalculate = DateTime.now().month;
    for (Investment inv in investments) {
      if (!isHistory) {
        if (inv.date.month == monthToCalculate) sum += inv.amount;
      } else
        sum += inv.amount;
    }
    return sum;
  }

  int get totalSpending {
    var sum = 0;
    for (var i = 0; i < investments.length; i++) {
      sum += investments[i].amount;
    }
    return sum;
  }

  Widget inviteUserWidget(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(' '),
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54, width: 3.0)),
          child: InkWell(
            onTap: () {
              inviteUserToApartment(context);
            },
            child: CircleAvatar(
              radius: screenSize.height * 0.04,
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
        // SizedBox(height: 2),

        // SizedBox(height: 2),
      ],
    );
  }

  inviteUserToApartment(BuildContext context) async {
    final toShare = await _createDynamicLink(context);
    try {
      Share.share(toShare);
    } catch (e) {
      print(e);
    }
  }

  Future<String> _createDynamicLink(BuildContext context) async {
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

  _userRow(List<DiraUser> userList, ThemeData theme, BuildContext context) {
    final toReturn = userList.map((data) {
      return _buildUserInfo(data, theme, context, userList);
    }).toList();
    if (userList.length == 1) {
      toReturn.insert(0, inviteUserWidget(context));
      // toReturn.insert(1, Divider(thickness: 10, color: Colors.green));
    }
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final Brightness brightnessValue =
    //     MediaQuery.of(context).platformBrightness;
    final userList = Provider.of<List<DiraUser>>(context, listen: false);
    for (int i = 0; i < userList.length; i++)
      initUserinvestmentSumMap(userList[i].uid);
    return Container(
      // color: brightnessValue == Brightness.dark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _userRow(userList, theme, context),
              ),
            ),
            // ),
            // Expanded(
            //   flex: 1,
            //   child:
            Container(
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
                    '₪' + monthlySpendings.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ],
              ),
            ),
            // ),
            if (isHistory) _chartIcon(investments, context),
          ],
        ),
      ),
    );
  }

  _chartIcon(List<Investment> investments, BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.insert_chart_outlined,
        size: 30,
        color: Colors.blue,
      ),
      onPressed: () => SpendingsChart.show(context, investments),
    );
  }

  int _eachShouldSpend() {
    return (totalSpending ~/ userInvestmentSum.length);
  }

  Widget _buildUserInfo(DiraUser user, ThemeData theme, BuildContext context,
      List<DiraUser> userList) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            user.disaplayName != null ? user.disaplayName : 'אנונימי',
            style: theme.textTheme.headline6
                .copyWith(fontSize: 12, color: Colors.black),
          ),
        ),
        Avatar(
          photoUrl: user.photoUrl,
          radius: screenSize.height * 0.04,
        ),
        // SizedBox(height: 6),
        AutoSizeText(
          'הוציא: ' + '₪' + userInvestmentSum[user.uid].toString(),
          style: theme.textTheme.headline6.copyWith(fontSize: 13),
        ),
        // SizedBox(height: 6),
        if (userList.length > 1) Center(child: shouldGetOrAdd(user.uid)),
        SizedBox(height: 6),
      ],
    );
  }

  Text shouldGetOrAdd(String uid) {
    var color;
    var text;
    var spent = userInvestmentSum[uid];
    var getOrAdd = _eachShouldSpend() - spent;
    if (getOrAdd <= 0) {
      color = Colors.green;
      text = 'צריך לקבל: ';
    } else {
      color = Colors.red;
      text = 'צריך לתת: ';
    }
    return Text(
      '    ' + text + '₪' + getOrAdd.abs().toString() + '    ',
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
    );
  }

  List<Investment> userInvestments(String uid) {
    List<Investment> toReturn;
    userInvestmentSum[uid] = 0;
    investments.forEach((inv) {
      if (inv.ownerUid == uid) {
        toReturn.add(inv);
      }
    });
    return toReturn;
  }

  List<Investment> initUserinvestmentSumMap(String uid) {
    List<Investment> toReturn;
    userInvestmentSum[uid] = 0;
    investments.forEach((inv) {
      if (inv.ownerUid == uid) {
        userInvestmentSum[uid] += inv.amount.toInt();
      }
    });
    return toReturn;
  }
}
