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
    final userList = Provider.of<List<User>>(context);
    for (int i = 0; i < userList.length; i++)
      initUserinvestmentSumMap(userList[i].uid);
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: userList.map((data) {
                    return _buildUserInfo(data, theme);
                  }).toList(),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'הוצאות דירה כוללות:',
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                    Text(
                      totalSpending.toString() + '₪',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _eachShouldSpend() {
    return (totalSpending ~/ userInvestmentSum.length);
  }

  Widget _buildUserInfo(User user, ThemeData theme) {
    return Wrap(
      runAlignment: WrapAlignment.center,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      direction: Axis.vertical,
      children: <Widget>[
        if (user.disaplayName != null)
          Text(
            user.disaplayName,
            style: theme.textTheme.title
                .copyWith(fontSize: 14, color: Colors.black),
          ),
        Avatar(
          photoUrl: user.photoUrl,
          radius: 25,
        ),
        SizedBox(height: 8),
        Text(
          'הוציא: ' + userInvestmentSum[user.uid].toString() + '₪',
          style: theme.textTheme.title.copyWith(fontSize: 14),
        ),
        SizedBox(height: 8),
        Center(child: shouldGetOrAdd(user.uid)),
        SizedBox(height: 8),
      ],
    );
  }

  Text shouldGetOrAdd(String uid) {
    var color;
    var text;
    var spent = userInvestmentSum[uid];
    var getOrAdd = _eachShouldSpend() - spent;
    if (getOrAdd < 0) {
      color = Colors.green;
      text = 'צריך לקבל: ';
    } else {
      color = Colors.red;
      text = 'צריך לתת: ';
    }
    return Text(
      text + getOrAdd.abs().toString() + '₪',
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
