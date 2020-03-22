import 'package:dira_nedira/Services/api_path.dart';
import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/firestore_service.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart';

abstract class Database {
  Future<void> createInvestment(Investment investment, String apartmentId);
  Stream<List<Investment>> investmentsStream(
      String apartmentId, String yearMonth);
  Future<void> deleteInvestment(Investment investment, String apartmentId);
  Future<void> createApartment(Apartment apartment);
  Future<bool> doesApartmentIdExist(String apartmentId);
  Stream<String> apartmentIdStream();
  Future<void> addUserDataToApartment(
      {String apartmentId, Map<String, dynamic> data});
  Future<bool> loginToApartment({String apartmentId, String pass});
  Future<void> setUserApartment(String apartmentId);
  Future<void> leaveApartment(String apartmentId);
  Future<Apartment> getApartmentById(String aptId);
  Stream<Apartment> apartmentStream(String apartmentId);
  Stream<List<User>> userStream(String apartmentId);
  Future<String> getUserPicUrlById(String uid);
  Future<List<String>> getMonthsWithTransactions(
      String apartmentId, List<String> months);
  Future<void> initMonthSumToZero(String apartmentId, String currentMonthYear);
  Future<Map<String, dynamic>> getMonthlySumDoc(String apartmentId);
  Future<List<Investment>> getInvestmentsByMonthYear(
      String monthYear, String apartmentId);
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;
  final _service = FirestoreService.instace;

  @override
  Future<void> createInvestment(
      Investment investment, String apartmentId) async {
    String monthYear = DateFormat.yMMM().format(investment.date);
    String pathToMonthlySumDoc = APIPath.monthlySumDoc(apartmentId);
    String pathToWritePayment = APIPath.investment(
        apartmentId, investment.id, DateFormat.yMMM().format(investment.date));
    Map<String, dynamic> paymentData = investment.toMap();
    int investmentAmount = investment.amount;
    return _service.addInvestmentTransaction(pathToMonthlySumDoc,
        pathToWritePayment, monthYear, investmentAmount, paymentData);
  }
  // _service.setData(
  //   path: APIPath.investment(apartmentId, investment.id,
  //       DateFormat.yMMM().format(investment.date)),
  //   data: investment.toMap(),
  // );

  @override
  Future<void> deleteInvestment(
      Investment investment, String apartmentId) async {
    String pathToMonthlySumDoc = APIPath.monthlySumDoc(apartmentId);
    String pathToInvestment = APIPath.investment(
        apartmentId, investment.id, DateFormat.yMMM().format(investment.date));
    String monthYear = DateFormat.yMMM().format(investment.date);
    int investmentAmount = investment.amount;

    await _service.deleteInvestmentTransaction(
        pathToMonthlySumDoc, pathToInvestment, monthYear, investmentAmount);
  }
  // await _service.deleteData(
  //     path: APIPath.investment(apartmentId, investment.id,
  //         DateFormat.yMMM().format(investment.date)));

  @override
  Future<Map<String, dynamic>> getMonthlySumDoc(String apartmentId) async {
    print('fetching sum doc'); //TODO debug print
    return await _service.getDocumentByPath(APIPath.monthlySumDoc(apartmentId));
  }

  @override
  Future<List<Investment>> getInvestmentsByMonthYear(
      String monthYear, String apartmentId) async {
    return await _service.getCollection(
        path: APIPath.investments(apartmentId, monthYear),
        builder: (data, documentId) => Investment.fromMap(data, documentId));
  }

  @override
  Stream<List<Investment>> investmentsStream(
          String apartmentId, String yearMonth) =>
      _service.collectionStream(
          path: APIPath.investments(apartmentId, yearMonth),
          builder: (data, documentId) => Investment.fromMap(data, documentId));

  @override
  Stream<List<User>> userStream(String apartmentId) =>
      _service.collectionStream(
          path: APIPath.apartmentUsers(apartmentId),
          builder: (data, documentId) => User.fromMap(data));

  @override
  Stream<String> apartmentIdStream() {
    return _service.apartmentIdStream(
      path: APIPath.users(),
      uid: uid,
      builder: (data) => Apartment.idFromMap(data),
    );
  }

  @override
  Future<void> createApartment(Apartment apartment) async {
    await _service.setData(path: APIPath.user(uid), data: apartment.idToMap());
    return await _service.setData(
        path: APIPath.apartment(apartment.id), data: apartment.toMap());
  }

//maybe automatically delete apartment: if the last user leaves the apartment, he will get a warning saying if he'll leave the apartment's data will be deleted
  @override
  Future<bool> doesApartmentIdExist(String apartmentId) async {
    return await _service.doesApartmentIdExist(apartmentId);
  }

  @override
  Future<Apartment> getApartmentById(String aptId) {
    //TODO: implement and use after the apartmentId stream
  }

  @override
  Future<void> addUserDataToApartment(
      {String apartmentId, Map<String, dynamic> data}) async {
    return await _service.setData(
      path: APIPath.userInApartment(apartmentId: apartmentId, uid: data['uid']),
      data: data, //TODO: add user display name
    ); //TODO: try writing a user dociment with no fields instead of a "uid" field
  }

  @override
  Future<bool> loginToApartment({String apartmentId, String pass}) async {
    return await _service.loginToApartment(
        apartmentId: apartmentId, pass: pass);
  }

  @override
  Future<void> setUserApartment(String apartmentId) async {
    await _service
        .setData(path: APIPath.user(uid), data: {'apartmentId': apartmentId});
  }

  Future<void> leaveApartment(String apartmentId) async {
    await _service.deleteData(
      path: APIPath.userInApartment(apartmentId: apartmentId, uid: uid),
    );
    await setUserApartment(null);
  }

  Stream<Apartment> apartmentStream(String apartmentId) {
    return _service.apartmentStream(
        path: APIPath.apartments(),
        apartmentId: apartmentId,
        builder: (data) => Apartment.fromMap(data, apartmentId));
  }

  @override
  Future<String> getUserPicUrlById(String uid) {
    return _service.userPhotoUrl(APIPath.users(), uid);
  }

  @override
  Future<List<String>> getMonthsWithTransactions(
      String apartmentId, List<String> months) {
    return _service.monthsWithTransactions(months, APIPath.months(apartmentId));
  }

  @override
  Future<void> initMonthSumToZero(String apartmentId, String monthYear) async {
    String pathToSumDoc = APIPath.monthlySumDoc(apartmentId);
    return await _service.initNewMonthInMonthlySumDoc(pathToSumDoc, monthYear);
  }
}
