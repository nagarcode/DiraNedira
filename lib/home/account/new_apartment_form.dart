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
        final data = widget.user.dataMap();
        if (isTaken) {
          PlatformAlertDialog(
            title: 'Apartment ID taken',
            content: 'id taken, please choose a different id',
            defaultActionText: 'OK',
          ).show(context);
        } else {
          final apartment = Apartment(
            id: _id,
            password: _password,
          );
          await widget.database.createApartment(apartment);
          await widget.database
              .addUserDataToApartment(apartmentId: _id, data: data);
          Navigator.of(context).pop();
        }
      } on PlatformException catch (e) {
        PlatformExceptionAlertDialog(
          title: 'Operation Failed',
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
    if (id.isEmpty) return 'id can\'t be empty';
    if (id.length > 12) return 'Must be less than 20 chars';
    if (id.length < 4) return 'Must be over 4 chars';
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
    if (pass.length < 4) return 'Pass must be over 4 chars';
    if (pass.isEmpty) return 'Password can\'t be empty';
    if (pass.length > 15) return 'Pass must be less than 15 chars long';
    if (isAlpha(pass) || isNumeric(pass))
      return 'Pass must contain letters AND numbers';
    return null;
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        decoration: InputDecoration(labelText: 'id'),
        validator: apartmentIdValidator,
        onSaved: (value) => _id = value,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Password'),
        validator: apartmentPasswordValidator,
        onSaved: (value) => _password = value,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Confirm Password'),
        validator: (value) {
          if (value == _password)
            return null;
          else
            return 'Passwords dont match';
        },
        onSaved: (value) => _confirmPass = value,
      ),
      RaisedButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        color: Theme.of(context).primaryColor,
        child: Text('Create Apartment'),
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
