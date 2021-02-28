import 'package:auto_size_text/auto_size_text.dart';
import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/platform_alert_dialog.dart';
import 'package:dira_nedira/common_widgets/platform_exception_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:flutter/services.dart';
import 'package:string_validator/string_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class NewApartmentForm extends StatefulWidget {
  const NewApartmentForm(
      {@required this.database, this.apartment, @required this.user});
  final Database database;
  final DiraUser user;
  final Apartment apartment;

  static Future<void> show(BuildContext context, {Apartment apartment}) async {
    final database = Provider.of<Database>(context, listen: false);
    final user = Provider.of<DiraUser>(context, listen: false);
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (bCtx) {
        return NewApartmentForm(
          database: database,
          apartment: apartment,
          user: user,
        );
      },
    );
  }

  @override
  _NewApartmentFormState createState() => _NewApartmentFormState();
}

class _NewApartmentFormState extends State<NewApartmentForm> {
  final _formKey = GlobalKey<FormState>();

  String _id;
  String _password;
  // ignore: unused_field
  String _confirmPass;

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
    if (_validateAndSaveForm()) {
      try {
        final apartmentId = _id;
        final isTaken = await isApartmentIdTaken(apartmentId);
        // final data = widget.user.dataMap();
        if (isTaken) {
          PlatformAlertDialog(
            title: 'שם דירה תפוס',
            content: 'דירה אחרת כבר משתמשת בשם הזה, אנא בחר שם אחר',
            defaultActionText: 'אישור',
          ).show(context);
        } else {
          final apartment = Apartment(
            id: _id,
            password: _password,
          );
          await widget.database
              .createApartment(apartment, widget.user.dataMap());
          // await widget.database
          //     .addUserDataToApartment(apartmentId: _id, data: data);
          Navigator.of(context).pop();
        }
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

  String apartmentIdValidator(String id) {
    if (id.isEmpty) return 'שם דירה לא יכול להיות ריק';
    if (id.length > 25) return 'לכל היותר 25 תווים';
    if (id.length < 4) return 'לכל הפחות 4 תווים';
    if (id == "null") return 'אל תקריס אותי..';
    return null;
  }

  Future<bool> isApartmentIdTaken(String id) async {
    final output = await widget.database
        .doesApartmentIdExist(id)
        .then((onValue) => onValue);
    return output;
  }

  String apartmentPasswordValidator(String pass) {
    _password = pass;
    if (pass.length < 4) return 'אורך סיסמא מינימלי הוא 4 תווים';
    if (pass.isEmpty) return 'שדה חובה';
    if (pass.length > 15) return 'לכל היותר 15 תווים';
    if (isAlpha(pass) || isNumeric(pass))
      return 'סיסמא חייבת להכיל אותיות ותווים';
    return null;
  }

  String matchingPasswordsValidator(String confirmPass) {
    if (confirmPass == _password)
      return null;
    else
      return 'חוסר התאמה בין הסיסמאות';
  }

  List<Widget> _buildFormChildren() {
    return [
      Container(
        margin: EdgeInsets.only(bottom: 20.0),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
        // ..translate(-10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: AutoSizeText(
          'צור דירה חדשה',
          maxLines: 1,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 30,
            fontFamily: 'Anton',
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      Divider(thickness: 1.0),
      TextFormField(
        autofocus: true,
        decoration:
            InputDecoration(labelText: 'שם דירה', prefixIcon: Icon(Icons.home)),
        validator: apartmentIdValidator,
        onSaved: (value) => _id = value,
      ),
      TextFormField(
        obscureText: true,
        decoration: InputDecoration(
            labelText: 'צור סיסמא', prefixIcon: Icon(Icons.lock)),
        validator: apartmentPasswordValidator,
        onSaved: (value) => _password = value,
      ),
      TextFormField(
        obscureText: true,
        decoration: InputDecoration(
            labelText: 'אשר סיסמא', prefixIcon: Icon(Icons.lock)),
        validator: matchingPasswordsValidator,
        onSaved: (value) => _confirmPass = value,
      ),
      RaisedButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        color: Theme.of(context).primaryColor,
        child: Text('צור דירה'),
        textColor: Theme.of(context).textTheme.button.color,
        onPressed: _submitData,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
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
