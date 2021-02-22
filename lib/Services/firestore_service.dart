import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  FirestoreService._();
  static final instace = FirestoreService._();

  Future<void> setData(
      {@required String path, Map<String, dynamic> data}) async {
    debugPrint("firebase request: " + data.toString());
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.set(data);
  }

  Future<void> appendData(
      {@required String path, Map<String, dynamic> data}) async {
    debugPrint("firebase request: " + data.toString());
    final reference = FirebaseFirestore.instance.doc(path);
    final setOptions = SetOptions(merge: true);
    await reference.set(data, setOptions);
  }

  Future<List<T>> getCollection<T>(
      {String path,
      T builder(Map<String, dynamic> data, String documentId)}) async {
    debugPrint("firebase request: getting collection:" + path);
    final reference = FirebaseFirestore.instance.collection(path);
    final snap = await reference.get();
    return snap.docs
        .map((snapshot) => builder(snapshot.data(), snapshot.id))
        .toList();
  }

  Stream<List<T>> collectionStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentId),
  }) {
    debugPrint('firebase request: Getting collection stream: $path');
    final reference = FirebaseFirestore.instance.collection(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => snapshot.docs
        .map(
          (snapshot) => builder(snapshot.data(), snapshot.id),
        )
        .toList());
  }

  Stream<String> apartmentIdStream(
      {@required String path,
      @required String uid,
      String builder(Map<String, dynamic> data)}) {
    debugPrint('firebase request: Getting ApartmentId stream:');
    final reference = FirebaseFirestore.instance.collection(path).doc(uid);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data()));
  }

  Future<bool> doesApartmentIdExist(String id) async {
    debugPrint('firebase request: Getting does apartment exists boolean');
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('apartments')
          .doc(id)
          .get();
      if (snapShot == null || !snapShot.exists) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> loginToApartment({String apartmentId, String pass}) async {
    debugPrint('firebase request: Logging in to apartment');
    final snapshot = await FirebaseFirestore.instance
        .collection('apartments')
        .doc(apartmentId)
        .get();
    if (snapshot.exists) {
      final map = snapshot.data();
      final apartmentPassword = map['password'];
      return pass == apartmentPassword;
    } else
      return null;
  }

  Stream<Apartment> apartmentStream(
      {@required String path,
      String apartmentId,
      Apartment builder(Map<String, dynamic> data)}) {
    debugPrint('firebase request: Getting Apartment Stream');
    final reference =
        FirebaseFirestore.instance.collection(path).doc(apartmentId);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data()));
  }

  Future<Map<String, dynamic>> getDocumentByPath(String path) async {
    debugPrint('firebase request: Getting doc by path: ' + path);
    final docReference = await FirebaseFirestore.instance.doc(path).get();
    if (docReference.exists)
      return docReference.data();
    else
      return null;
  }

  Future<void> deleteData({@required String path}) async {
    debugPrint('firebase request: Deleting: ' + path);
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.delete();
  }

  Future<void> toggleCheckbox(
      String docPath, String itemId, Map<String, dynamic> newState) async {
    debugPrint('firebase request: Changing checkbox status');
    final docRef = FirebaseFirestore.instance.doc(docPath);
    final SetOptions setOptions = SetOptions(merge: true);
    return docRef.set({itemId: newState}, setOptions);
  }

  Stream<List<T>> singleDocCollectionStream<T>(
      {@required String path,
      @required T builder(Map<String, dynamic> data, String documentId)}) {
    debugPrint('firebase request: Single doc collection stream: $path');
    final reference = FirebaseFirestore.instance.doc(path);
    final snapshots = reference.snapshots();
    return snapshots.map(
      (snapshot) {
        List<T> list = [];
        T t;
        final data = snapshot.data();
        data.forEach((key, value) {
          value = Map<String, dynamic>.from(value);
          t = builder(value, key);
          list.add(t);
        });
        return list;
      },
    );
  }

  Future<void> addFieldToSingleDoc(
      {@required String docPath,
      @required String fieldId,
      @required Map<String, dynamic> field}) async {
    debugPrint('firebase request: Adding field $fieldId to doc $docPath');
    final reference = FirebaseFirestore.instance.doc(docPath);
    final SetOptions setOptions = SetOptions(merge: true);
    return await reference.set({fieldId: field}, setOptions);
  }

  Future<void> deleteFieldFromSingleDoc({
    @required String docPath,
    @required String fieldId,
  }) async {
    debugPrint('firebase request: Deleting field $fieldId Single doc $docPath');

    final reference = FirebaseFirestore.instance.doc(docPath);
    final SetOptions setOptions = SetOptions(merge: true);

    return await reference.set({fieldId: FieldValue.delete()}, setOptions);
  }

  Future<void> deleteMultipleFieldsFromSingleDoc(
      String docPath, List<String> idsToDelete) async {
    debugPrint('firebase request: Deleting multiple fields from Single doc');

    final Map<String, FieldValue> deleteMap = {};
    for (String id in idsToDelete) deleteMap[id] = FieldValue.delete();
    final reference = FirebaseFirestore.instance.doc(docPath);
    final SetOptions setOptions = SetOptions(merge: true);

    return await reference.set(deleteMap, setOptions);
  }
}
