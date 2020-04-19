import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/common_widgets/adaptive_flat_button.dart';
import 'package:dira_nedira/common_widgets/platform_exception_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewInvestmentForm extends StatefulWidget {
  const NewInvestmentForm(
      {@required this.database,
      this.investment,
      @required this.user,
      @required this.apartmentId});
  final Database database;
  final User user;
  final Investment investment;
  final String apartmentId;

  static Future<void> show(BuildContext context,
      {Investment investment}) async {
    final database = Provider.of<Database>(context);
    final user = Provider.of<User>(context);
    final apartment = Provider.of<Apartment>(context);
    await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (bCtx) {
        return NewInvestmentForm(
          database: database,
          investment: investment,
          user: user,
          apartmentId: apartment.id,
        );
      },
    );
  }

  @override
  _NewInvestmentFormState createState() => _NewInvestmentFormState();
}

class _NewInvestmentFormState extends State<NewInvestmentForm> {
  final _formKey = GlobalKey<FormState>();
  String _title;
  int _amount;
  DateTime _selectedDate = DateTime.now();

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
        final uid = widget.user.uid;
        final id = widget.investment?.id ?? documentIdFromCurrentDate();
        final photoUrl = widget.user.photoUrl;
        final investment = Investment(
            amount: _amount,
            title: _title,
            date: _selectedDate,
            id: id,
            ownerPhotoUrl: photoUrl,
            ownerUid: uid);
        await widget.database.createInvestment(investment, widget.apartmentId);
        Navigator.of(context).pop();
      } on PlatformException catch (e) {
        PlatformExceptionAlertDialog(
          title: 'כשל',
          exception: e,
        ).show(context);
      } finally {}
    }
  }

  void _presentDatePicker() {
    final now = DateTime.now();
    // Platform.isIOS
    //     ? CupertinoDatePicker(
    //         mode: CupertinoDatePickerMode.date,
    //         minimumDate: DateTime(DateTime.now().year - 1),
    //         maximumDate: DateTime(DateTime.now().year + 1),
    //         initialDateTime: DateTime.now(),
    //         onDateTimeChanged: (DateTime newDate) {
    //           setState(() {
    //             _selectedDate = newDate;
    //           });
    //         },
    //       )
    showDatePicker(
            context: context,
            initialDate: now,
            firstDate: now.subtract(Duration(days: 3100)),//TODO make 31
            lastDate: now)
        .then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
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
        decoration: InputDecoration(labelText: 'שם הוצאה'),
        validator: (value) => value.isNotEmpty ? null : 'שם הוצאה לא יכול להיות ריק',
        onSaved: (value) => _title = value,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'סכום'),
        validator: (value) =>
            value.isNotEmpty ? null : 'סכום לא יכול להיות ריק',
        keyboardType: TextInputType.numberWithOptions(decimal: false),
        onSaved: (value) => _amount = int.tryParse(value) ?? 0,
      ),
      Container(
        height: 70,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(_selectedDate == null
                  ? 'לא נבחר תאריך'
                  : 'התאריך שנבחר: ${DateFormat.yMMMd().format(_selectedDate)}'),
            ),
            AdaptiveFlatButton(
              text: 'בחר תאריך',
              handler: _presentDatePicker,
            )
          ],
        ),
      ),
      RaisedButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        color: Theme.of(context).primaryColor,
        child: Text('הוסף הוצאה'),
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
