import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/avatar.dart';
import 'package:dira_nedira/common_widgets/platform_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/home/account/new_shopping_item_form.dart';
import 'package:dira_nedira/home/account/shopping_item.dart';
import 'package:flutter/material.dart';

class ShoppingList extends StatelessWidget {
  final List<ShoppingItem> shoppingList;
  final Apartment apartment;
  final Database database;
  final User user;

  ShoppingList(this.shoppingList, this.apartment, this.database, this.user);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            InkWell(
              onTap: () => _confirmClearCheckedItems(context),
              child: Text('נקה',
                  style: theme.textTheme.bodyText1
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
            Center(
              child: Text(
                'רשימת קניות משותפת',
                style: theme.textTheme.headline6,
              ),
            ),
            addShoppingItemButton(context),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),
        shoppingList == null || shoppingList.isEmpty
            ? Center(
                child: Center(
                  child: Text(
                    'רשימת קניות משותפת לכל הדיירים. לחץ על ה+ הכחול כדי להוסיף פריטים וכל חברי הדירה יוכלו לראות אותם.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : shoppingListView(theme),
      ],
    );
  }

  Future<void> _confirmClearCheckedItems(BuildContext context) async {
    final didRequestClear = await PlatformAlertDialog(
      title: 'נקה רשימה',
      content: 'האם אתה בטוח שברצונך לנקות את כל הפריטים המסומנים ברשימה?',
      defaultActionText: 'נקה',
      cancelActionText: 'בטל',
    ).show(context);
    if (didRequestClear) _clearCheckedItems();
  }

  _clearCheckedItems() async {
    final List<ShoppingItem> list = [];
    for (ShoppingItem item in shoppingList) if (item.checked) list.add(item);
    database.deleteShoppingListItems(apartment, list);
  }

  Widget shoppingListView(ThemeData theme) {
    shoppingList.sort((a, b) {
      final aInt = a.checked ? 1 : 0;
      final bInt = b.checked ? 1 : 0;
      return aInt - bInt;
    });
    return Expanded(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: shoppingList.length,
          itemBuilder: (ctx, index) {
            return ListTile(
              leading: Checkbox(
                  activeColor: Colors.lightBlue,
                  value: shoppingList[index].checked,
                  onChanged: (newVal) {
                    changeCheckedStatus(index);
                  }),
              enabled: !shoppingList[index].checked,
              title: Text(
                shoppingList[index].title,
                // style: theme.textTheme.bodyText2,
              ),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Avatar(
                  photoUrl: shoppingList[index].authorPhotoUrl,
                  radius: 10,
                ),
              ]),
            );
          }),
    );
  }

  changeCheckedStatus(int index) {
    final item = shoppingList[index];
    database.toggleCheckedState(item, apartment);
  }

  Widget addShoppingItemButton(BuildContext context) => IconButton(
        icon: Icon(Icons.add, color: Colors.lightBlue),
        onPressed: () {
          if (apartment != null)
            return NewShoppingItemForm.show(context,
                apartment: apartment, database: database, user: user);
          else
            return null;
        },
      );
}
