import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/platform_exception_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/home/account/shopping_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewShoppingItemForm extends StatefulWidget {
  const NewShoppingItemForm(
      {@required this.database, this.apartment, this.user});
  final Database database;
  final DiraUser user;
  final Apartment apartment;

  static Future<void> show(BuildContext context,
      {Apartment apartment, Database database, DiraUser user}) async {
    await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (bCtx) {
        return NewShoppingItemForm(
          database: database,
          apartment: apartment,
          user: user,
        );
      },
    );
  }

  @override
  _NewShoppingItemFormState createState() => _NewShoppingItemFormState();
}

class _NewShoppingItemFormState extends State<NewShoppingItemForm> {
  final _formKey = GlobalKey<FormState>();
  String _title;
  var isLoading = false;

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submitData() async {
    final apartmentId = widget.apartment.id;
    if (_validateAndSaveForm()) {
      try {
        final title = _title;
        final checked = false;
        final photoUrl = widget.user.photoUrl;
        final id = documentIdFromCurrentDate();
        final shoppingItem = ShoppingItem(
            title: title, authorPhotoUrl: photoUrl, checked: checked, id: id);
        await widget.database.addShoppingListItem(shoppingItem, apartmentId);
        Navigator.of(context).pop();
      } on PlatformException catch (e) {
        PlatformExceptionAlertDialog(
          title: 'כשל',
          exception: e,
        ).show(context);
      } finally {}
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        maxLength: 30,
        autofocus: true,
        decoration: InputDecoration(labelText: 'מוצר לקניה'),
        validator: shoppingItemValidator,
        onSaved: (value) => _title = value,
      ),
      RaisedButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        color: Theme.of(context).primaryColor,
        child: Text('הוסף לרשימה המשותפת'),
        textColor: Theme.of(context).textTheme.button.color,
        onPressed: _submitData,
      )
    ];
  }

  String shoppingItemValidator(String title) {
    if (title.isEmpty) return 'שם מוצר לא יכול להיות ריק';
    if (title.length > 30) return 'לכל היותר 20 תווים';
    if (title.length < 2) return 'לכל הפחות 2 תווים';
    if (title == "null") return 'אל תקריס אותי..';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Card(
              elevation: 5,
              child: Container(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                child: _buildForm(),
              ),
            ),
          );
  }
}
