import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  FirestoreService._();
  static final instace = FirestoreService._();

  Future<void> setData(
      {@required String path, Map<String, dynamic> data}) async {
    final reference = Firestore.instance.document(path);
    await reference.setData(data);
  }

  Stream<List<T>> collectionStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentId),
  }) {
    print('collection streaming: $path'); //TODO delete
    final reference = Firestore.instance.collection(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => snapshot.documents
        .map(
          (snapshot) => builder(snapshot.data, snapshot.documentID),
        )
        .toList());
  }

  Stream<String> apartmentIdStream(
      {@required String path,
      @required String uid,
      String builder(Map<String, dynamic> data)}) {
    final reference = Firestore.instance.collection(path).document(uid);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data));
  }

  Future<void> deleteData({@required String path}) async {
    final reference = Firestore.instance.document(path);
    print('delete: $path');
    await reference.delete();
  }

  Future<bool> doesApartmentIdExist(String id) async {
    try {
      final snapShot =
          await Firestore.instance.collection('apartments').document(id).get();
      if (snapShot == null || !snapShot.exists) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> loginToApartment({String apartmentId, String pass}) async {
    final snapshot = await Firestore.instance
        .collection('apartments')
        .document(apartmentId)
        .get();
    final map = snapshot.data;
    final apartmentPassword = map['password'];
    return pass == apartmentPassword;
  }

  Stream<Apartment> apartmentStream(
      {@required String path,
      String apartmentId,
      Apartment builder(Map<String, dynamic> data)}) {
    final reference = Firestore.instance.collection(path).document(apartmentId);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data));
  }

  Future<String> userPhotoUrl(String path, String uid) async {
    final snapshot =
        await Firestore.instance.collection(path).document(uid).get();
    final map = snapshot.data;
    final url = map['photoUrl'];
    return url;
  }

  Future<List<String>> monthsWithTransactions(
      List<String> months, String path) async {
    List<String> output;
    for (String month in months) {
      final doesMonthHaveTransactions = await Firestore.instance
          .collection(path + '$month/')
          .limit(1)
          .getDocuments();
      if (doesMonthHaveTransactions.documents.length != 0) output.add(month);
    }
    print('output:' + output.toString());
    return output;
  }
}
