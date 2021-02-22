import 'package:dira_nedira/Services/api_path.dart';
import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/firestore_service.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/home/account/shopping_item.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:meta/meta.dart';

abstract class Database {
  Future<void> createInvestment(Investment investment, String apartmentId);
  Stream<List<ShoppingItem>> singleDocShoppingItemStream(String apartmentId);
  Stream<List<Investment>> singleDocInvestmentsStream(String apartmentId);
  Future<void> deleteInvestment(Investment investment, String apartmentId);
  Future<void> createApartment(
      Apartment apartment, Map<String, dynamic> userData);
  Future<bool> doesApartmentIdExist(String apartmentId);
  Stream<String> apartmentIdStream();
  Future<void> addUserDataToApartment(
      {String apartmentId, Map<String, dynamic> data});
  Future<bool> loginToApartment({String apartmentId, String pass});
  Future<void> setUserApartment(String apartmentId);
  Future<void> leaveApartment(String apartmentId);
  Stream<Apartment> apartmentStream(String apartmentId);
  Future<void> addShoppingListItem(ShoppingItem item, String apartmentId);
  Future<void> toggleCheckedState(
      ShoppingItem shoppingItem, Apartment apartment);
  Future<void> deleteShoppingItem(
      ShoppingItem shoppingItem, Apartment apartment);
  Future<void> deleteShoppingListItems(
      Apartment apartment, List<ShoppingItem> toDelete);
  Stream<List<DiraUser>> singleDocUserStream(String apartmentId);
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;
  final _service = FirestoreService.instace;

  Future<void> deleteShoppingListItems(
      Apartment apartment, List<ShoppingItem> toDelete) async {
    final docPath = APIPath.shoppingItemsSingleDoc(apartment.id);
    final List<String> idsToDelete = [];
    for (ShoppingItem item in toDelete) idsToDelete.add(item.id);
    return _service.deleteMultipleFieldsFromSingleDoc(docPath, idsToDelete);
  }

  @override
  Stream<List<Investment>> singleDocInvestmentsStream(String apartmentId) {
    final path = APIPath.invetmentsSingleDoc(apartmentId);
    return _service.singleDocCollectionStream(
        path: path,
        builder: (data, documentId) => Investment.fromMap(data, documentId));
  }

  @override
  Stream<List<DiraUser>> singleDocUserStream(String apartmentId) {
    final path = APIPath.usersSingleDoc(apartmentId);
    return _service.singleDocCollectionStream(
        path: path, builder: (data, documentId) => DiraUser.fromMap(data));
  }

  Stream<List<ShoppingItem>> singleDocShoppingItemStream(String apartmentId) {
    final path = APIPath.shoppingItemsSingleDoc(apartmentId);
    return _service.singleDocCollectionStream(
        path: path,
        builder: (data, documentId) => ShoppingItem.fromMap(data, documentId));
  }

  @override
  Future<void> addShoppingListItem(
      ShoppingItem item, String apartmentId) async {
    final docPath = APIPath.shoppingItemsSingleDoc(apartmentId);
    Map<String, dynamic> dataMap = item.toMap();
    return _service.addFieldToSingleDoc(
        docPath: docPath, fieldId: item.id, field: dataMap);
  }

  @override
  Future<void> createInvestment(
      Investment investment, String apartmentId) async {
    final docPath = APIPath.invetmentsSingleDoc(apartmentId);
    Map<String, dynamic> paymentData = investment.toMap();
    return _service.addFieldToSingleDoc(
        docPath: docPath, fieldId: investment.id, field: paymentData);
  }

  @override
  Future<void> deleteInvestment(
      Investment investment, String apartmentId) async {
    final docPath = APIPath.invetmentsSingleDoc(apartmentId);
    final fieldId = investment.id;
    return await _service.deleteFieldFromSingleDoc(
        docPath: docPath, fieldId: fieldId);
  }

  @override
  Stream<String> apartmentIdStream() {
    return _service.apartmentIdStream(
      path: APIPath.users(),
      uid: uid,
      builder: (data) => Apartment.idFromMap(data),
    );
  }

  @override
  Future<void> setUserApartment(String apartmentId) async {
    await _service.appendData(
        path: APIPath.user(uid), data: {'apartmentId': apartmentId});
  }

  @override
  Future<void> createApartment(
      Apartment apartment, Map<String, dynamic> userData) async {
    await _service.setData(path: APIPath.user(uid), data: apartment.idToMap());
    await _service.setData(
        path: APIPath.apartment(apartment.id), data: apartment.toMap());
    await _service
        .setData(path: APIPath.shoppingItemsSingleDoc(apartment.id), data: {});
    await _service.setData(
        path: APIPath.usersSingleDoc(apartment.id), data: {uid: userData});
    return await _service
        .setData(path: APIPath.invetmentsSingleDoc(apartment.id), data: {});
  }

  @override
  Future<void> addUserDataToApartment(
      {String apartmentId, Map<String, dynamic> data}) async {
    print('Adding user data to apartment. data: $data');
    final fieldId = data['uid'];
    final docPath = APIPath.usersSingleDoc(apartmentId);
    return await _service.addFieldToSingleDoc(
        docPath: docPath, fieldId: fieldId, field: data);
  }

  @override
  Future<bool> doesApartmentIdExist(String apartmentId) async {
    return await _service.doesApartmentIdExist(apartmentId);
  }

  @override
  Future<bool> loginToApartment({String apartmentId, String pass}) async {
    return await _service.loginToApartment(
        apartmentId: apartmentId, pass: pass);
  }

  @override
  Future<void> leaveApartment(String apartmentId) async {
    final docPath = APIPath.usersSingleDoc(apartmentId);
    await _service.deleteFieldFromSingleDoc(docPath: docPath, fieldId: uid);
    return await setUserApartment(null);
  }

  Stream<Apartment> apartmentStream(String apartmentId) {
    return _service.apartmentStream(
        path: APIPath.apartments(),
        apartmentId: apartmentId,
        builder: (data) => Apartment.fromMap(data, apartmentId));
  }

  @override
  Future<void> toggleCheckedState(
      ShoppingItem shoppingItem, Apartment apartment) async {
    String docPath = APIPath.shoppingItemsSingleDoc(apartment.id);
    final newState = shoppingItem.toMap();
    newState['checked'] = !newState['checked'];
    _service.toggleCheckbox(docPath, shoppingItem.id, newState);
  }

  @override
  Future<void> deleteShoppingItem(
      ShoppingItem shoppingItem, Apartment apartment) async {
    await _service.deleteData(
        path: APIPath.shoppingItemById(apartment.id, shoppingItem.id));
  }
}
