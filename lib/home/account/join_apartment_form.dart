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

class JoinApartmentForm extends StatefulWidget {
  const JoinApartmentForm(
      {@required this.database, this.apartment, @required this.user});
  final Database database;
  final User user;
  final Apartment apartment;

  static Future<void> show(BuildContext context, {Apartment apartment}) async {
    final database = Provider.of<Database>(context);
    final user = Provider.of<User>(context);
    await showModalBottomSheet(
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
        if (loginAttempt) {
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
    if (id.length > 12) return 'לכל היותר 20 תווים';
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
      TextFormField(
        decoration: InputDecoration(labelText: 'שם דירה'),
        validator: apartmentIdValidator,
        onSaved: (value) => _id = value,
      ),
      TextFormField(
        obscureText: true,
        decoration: InputDecoration(labelText: 'סיסמא'),
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
