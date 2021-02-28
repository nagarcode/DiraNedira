import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/platform_alert_dialog.dart';
import 'package:dira_nedira/common_widgets/platform_exception_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class JoinApartmentForm extends StatefulWidget {
  const JoinApartmentForm(
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
        return JoinApartmentForm(
          database: database,
          apartment: apartment,
          user: user,
        );
      },
    );
  }

  @override
  _JoinApartmentFormState createState() => _JoinApartmentFormState();
}

class _JoinApartmentFormState extends State<JoinApartmentForm> {
  final _formKey = GlobalKey<FormState>();

  String _id;
  String _password;
  //String _confirmPass;

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
        final pass = _password;
        final data = widget.user.dataMap();
        final loginAttempt = await widget.database
            .loginToApartment(apartmentId: apartmentId, pass: pass);
        if (loginAttempt == null) {
          PlatformAlertDialog(
            title: 'הצטרפות נכשלה',
            content: 'שם דירה זה לא קיים במערכת. נסה שוב',
            defaultActionText: 'אישור',
          ).show(context);
        } else if (loginAttempt) {
          widget.database.setUserApartment(apartmentId);
          widget.database
              .addUserDataToApartment(apartmentId: apartmentId, data: data);
          Navigator.of(context).pop();
        } else {
          PlatformAlertDialog(
            title: 'הצטרפות נכשלה',
            content: 'סיסמא לא נכונה, נסה שוב',
            defaultActionText: 'אישור',
          ).show(context);
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
    if (id.isEmpty) return 'שדה חובה';
    if (id.length > 25) return 'לכל היותר 25 תווים';
    if (id.length < 4) return 'לכל הפחות 4 תווים';
    return null;
  }

  Future<bool> doesApartmentIdExist(String id) async {
    final output = await widget.database
        .doesApartmentIdExist(id)
        .then((onValue) => onValue);
    return output;
  }

  String apartmentPasswordValidator(String pass) {
    if (pass.length < 4) return 'לכל הפחות 4 תווים';
    if (pass.isEmpty) return 'שדה חובה';
    if (pass.length > 15) return 'לכל היותר 15 תווים';
    return null;
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
          'הצטרף לדירה קיימת',
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
        decoration:
            InputDecoration(labelText: 'סיסמא', prefixIcon: Icon(Icons.lock)),
        validator: apartmentPasswordValidator,
        onSaved: (value) => _password = value,
      ),
      RaisedButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        color: Theme.of(context).primaryColor,
        child: Text('הצטרף לדירה'),
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
