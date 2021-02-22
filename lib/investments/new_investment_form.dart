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
      @required this.apartmentId,
      @required this.theme});
  final Database database;
  final DiraUser user;
  final Investment investment;
  final String apartmentId;
  final ThemeData theme;

  static Future<void> show(BuildContext context,
      {Investment investment}) async {
    final database = Provider.of<Database>(context, listen: false);
    final user = Provider.of<DiraUser>(context, listen: false);
    final apartment = Provider.of<Apartment>(context, listen: false);
    final theme = Theme.of(context);
    await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (bCtx) {
        return NewInvestmentForm(
            database: database,
            investment: investment,
            apartmentId: apartment.id,
            user: user,
            theme: theme);
      },
    );
  }

  @override
  _NewInvestmentFormState createState() => _NewInvestmentFormState();
}

class _NewInvestmentFormState extends State<NewInvestmentForm> {
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  String _title;
  int _amount;
  DateTime _selectedDate = DateTime.now();
  int _selectedColorIndex = 2;
  final colors = Investment.colors.keys.toList();
  @override
  void initState() {
    super.initState();
    isEditing = widget.investment != null;
    if (isEditing) _initEditingDate();
  }

  _initEditingDate() {
    setState(() {
      _selectedDate = widget.investment?.date;
      _selectedColorIndex = widget.investment?.colorIndex;
    });
  }

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
          ownerUid: uid,
          colorIndex: _selectedColorIndex,
        );
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
            initialDate: isEditing ? widget.investment?.date : now,
            firstDate: now.subtract(Duration(days: 360)),
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

  _selectColor(int index) {
    setState(() {
      _selectedColorIndex = index;
    });
  }

  _colorPicker() {
    final children = <Widget>[];
    children.add(Spacer(flex: 10));
    for (int i = 0; i < colors.length; i++) {
      children.add(
        Flexible(
          flex: 3,
          child: GestureDetector(
            onTap: () => _selectColor(i),
            child: Container(
              decoration: BoxDecoration(
                  color: colors[i],
                  border: Border.all(
                      color: _selectedColorIndex == i
                          ? Colors.lightBlue
                          : Colors.black54)),
              height: 20,
              width: 20,
            ),
          ),
        ),
      );
      if (i < 4) children.add(Spacer(flex: 1));
    }
    children.add(Spacer(flex: 10));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }

  _colorText() {
    final colorMap = Investment.colors;
    return Center(
      child: Text('\n' + colorMap.values.toList()[_selectedColorIndex],
          style: widget.theme.textTheme.caption.copyWith(fontSize: 13)),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      _colorPicker(),
      _colorText(),
      TextFormField(
        initialValue: widget.investment?.title,
        maxLength: 25,
        autofocus: true,
        decoration: InputDecoration(labelText: 'שם הוצאה'),
        validator: (value) =>
            value.isNotEmpty ? null : 'שם הוצאה לא יכול להיות ריק',
        onSaved: (value) => _title = value,
      ),
      TextFormField(
        enabled: !isEditing,
        initialValue: isEditing ? widget.investment?.amount.toString() : null,
        maxLength: 5,
        decoration: InputDecoration(labelText: 'סכום'),
        validator: (value) =>
            value.isNotEmpty ? null : 'סכום לא יכול להיות ריק',
        keyboardType:
            TextInputType.numberWithOptions(decimal: false, signed: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSaved: (value) {
          double amountDouble = 0;
          int amount = int.tryParse(value) ?? 0;
          if (amount == 0) amountDouble = double.tryParse(value) ?? 0;
          if (amountDouble != null && amountDouble != 0)
            amount = amountDouble.round();
          return _amount = amount;
        },
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
        // color: Theme.of(context).primaryColor,
        color: _selectedColorIndex == 2
            ? Theme.of(context).primaryColor
            : Investment.colors.keys.toList()[_selectedColorIndex],
        child: Text(isEditing ? 'שמור שינויים' : 'הוסף הוצאה'),
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
              // color: Investment.colors.keys.toList()[_selectedColorIndex],
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
