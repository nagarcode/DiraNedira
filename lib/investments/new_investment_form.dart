import 'package:cached_network_image/cached_network_image.dart';
import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/Services/firebase_storage_service.dart';
import 'package:dira_nedira/Services/image_picker_service.dart';
import 'package:dira_nedira/common_widgets/adaptive_flat_button.dart';
import 'package:dira_nedira/common_widgets/halturaDialog.dart';
import 'package:dira_nedira/common_widgets/platform_exception_alert_dialog.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:octo_image/octo_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class NewInvestmentForm extends StatefulWidget {
  const NewInvestmentForm({
    @required this.database,
    this.investment,
    @required this.user,
    @required this.apartmentId,
    @required this.theme,
    @required this.imagePicker,
    @required this.storage,
  });
  final Database database;
  final DiraUser user;
  final Investment investment;
  final String apartmentId;
  final ThemeData theme;
  final ImagePickerService imagePicker;
  final FirebaseStorageService storage;

  static Future<void> show(BuildContext context,
      {Investment investment}) async {
    final database = Provider.of<Database>(context, listen: false);
    final user = Provider.of<DiraUser>(context, listen: false);
    final apartment = Provider.of<Apartment>(context, listen: false);
    final theme = Theme.of(context);
    final imagePicker = Provider.of<ImagePickerService>(context, listen: false);
    final storage = Provider.of<FirebaseStorageService>(context, listen: false);

    await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      builder: (bCtx) {
        return NewInvestmentForm(
            imagePicker: imagePicker,
            storage: storage,
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
  String _imageURL;
  String _investmentID;
  bool _isLoadingImage = false;
  final colors = Investment.colors.keys.toList();
  @override
  void initState() {
    super.initState();
    _investmentID = widget.investment?.id ?? documentIdFromCurrentDate();
    isEditing = widget.investment != null;
    if (isEditing) _initEditingDate();
  }

  _initEditingDate() {
    setState(() {
      _selectedDate = widget.investment?.date;
      _selectedColorIndex = widget.investment?.colorIndex;
      _imageURL = widget.investment?.imageURL;
    });
  }

  _smallImage() {
    return OctoImage(
      image: CachedNetworkImageProvider(_imageURL),
      placeholderBuilder: OctoPlaceholder.circularProgressIndicator(),
      errorBuilder: OctoError.icon(color: Colors.red),
      fit: BoxFit.cover,
    );
  }

  Widget _imageUploadWidget() {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: _pickImage,
          child: Container(
            height: 60,
            width: 60,
            child: _imageURL == null
                ? Icon(Icons.camera_alt_outlined,
                    color: theme.primaryColor.withOpacity(0.6))
                : _smallImage(),
            decoration: BoxDecoration(
              border:
                  Border.all(width: 2.5, color: Colors.grey.withOpacity(0.6)),
              // color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
        // Text(
        //   'צירוף תמונה',
        //   style: theme.textTheme.bodyText2.copyWith(color: Colors.grey),
        // )
      ],
    );
  }

  void _permissionRequestDialog() {
    HalturaDialog(
      title: 'גישה לגלריה',
      content: 'נדרשת גישה לגלריה על מנת להעלות תמונה',
      defaultActionText: 'סגור',
    ).show(context);
  }

  _pickImage() async {
    final picker = widget.imagePicker;
    try {
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        _permissionRequestDialog();
      }
    } catch (e) {
      print('Permission ERROR!');
      print(e.toString());
    }

    try {
      final file = await picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        final storage = widget.storage;
        final downloadURL = await storage.uploadReviewImage(
            file: file,
            investmentID: _investmentID,
            apartmentID: widget.apartmentId);
        setState(() {
          _isLoadingImage = false;
          _imageURL = downloadURL;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      _permissionRequestDialog();
    }
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
        final photoUrl = widget.user.photoUrl;
        final investment = Investment(
          amount: _amount,
          title: _title,
          date: _selectedDate,
          id: _investmentID,
          ownerPhotoUrl: photoUrl,
          ownerUid: uid,
          colorIndex: _selectedColorIndex,
          imageURL: _imageURL,
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
    final colorList = Investment.colors.keys.toList();
    return [
      _colorPicker(),
      _colorText(),
      TextFormField(
        cursorColor: colorList[_selectedColorIndex],
        initialValue: widget.investment?.title,
        maxLength: 25,
        autofocus: true,
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorList[_selectedColorIndex])),
            labelText: 'שם הוצאה',
            labelStyle: TextStyle(color: Colors.grey)),
        validator: (value) =>
            value.isNotEmpty ? null : 'שם הוצאה לא יכול להיות ריק',
        onSaved: (value) => _title = value,
      ),
      TextFormField(
        cursorColor: colorList[_selectedColorIndex],
        enabled: !isEditing,
        initialValue: isEditing ? widget.investment?.amount.toString() : null,
        maxLength: 5,
        decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.grey),
            labelText: 'סכום',
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorList[_selectedColorIndex]))),
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
      _imageUploadWidget(),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
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
