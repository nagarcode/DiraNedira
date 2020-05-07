import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/common_widgets/avatar.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
  final List<Investment> investments;
  final Map<String, int> userInvestmentSum = new Map();

  Chart({this.investments});

  int get totalSpending {
    var sum = 0;
    for (var i = 0; i < investments.length; i++) {
      sum += investments[i].amount;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    final userList = Provider.of<List<User>>(context);
    for (int i = 0; i < userList.length; i++)
      initUserinvestmentSumMap(userList[i].uid);
    return Container(
      // color: brightnessValue == Brightness.dark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Expanded(
            //   flex: 3,
            // child: ListView.builder(
            //   itemCount: userList.length,
            //   itemBuilder: (ctx, index) {
            //     return Container(
            //       child: _buildUserInfo(userList[index], theme, context),
            //     );
            //   },
            //   scrollDirection: Axis.horizontal,
            // child:
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: userList.map((data) {
                  return _buildUserInfo(data, theme, context, userList);
                }).toList(),
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
                  Text(
                    'הוצאות דירה כוללות:',
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                  Text(
                    '₪' + totalSpending.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ],
              ),
            ),
            // ),
          ],
        ),
      ),
    );
  }

  int _eachShouldSpend() {
    return (totalSpending ~/ userInvestmentSum.length);
  }

  Widget _buildUserInfo(
      User user, ThemeData theme, BuildContext context, List<User> userList) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
        Text(
          'הוציא: ' + '₪' + userInvestmentSum[user.uid].toString(),
          style: theme.textTheme.headline6.copyWith(fontSize: 13),
        ),
        // SizedBox(height: 6),
        if (userList.length > 1)
          Center(child: shouldGetOrAdd(user.uid)),
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
