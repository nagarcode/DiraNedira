import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  FirestoreService._();
  static final instace = FirestoreService._();

  Future<void> setData(
      {@required String path, Map<String, dynamic> data}) async {
    print("firebase request: " + data.toString()); //TODO: Delete
    final reference = Firestore.instance.document(path);
    await reference.setData(data);
  }

  Future<List<T>> getCollection<T>(
      {String path,
      T builder(Map<String, dynamic> data, String documentId)}) async {
    print("firebase request: getting collection:" + path); //TODO: Delete
    final reference = Firestore.instance.collection(path);
    final snap = await reference.getDocuments();
    return snap.documents
        .map((snapshot) => builder(snapshot.data, snapshot.documentID))
        .toList();
  }

  Stream<List<T>> collectionStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentId),
  }) {
    print('firebase request: Getting collection stream: $path'); //TODO delete
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
    print('firebase request: Getting ApartmentId stream:'); //TODO delete
    final reference = Firestore.instance.collection(path).document(uid);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data));
  }

  Future<bool> doesApartmentIdExist(String id) async {
    print(
        'firebase request: Getting does apartment exists boolean'); //TODO delete
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
    print('firebase request: Logging in to apartment'); //TODO delete
    final snapshot = await Firestore.instance
        .collection('apartments')
        .document(apartmentId)
        .get();
    if (snapshot.exists) {
      final map = snapshot.data;
      final apartmentPassword = map['password'];
      return pass == apartmentPassword;
    } else
      return null;
  }

  Stream<Apartment> apartmentStream(
      {@required String path,
      String apartmentId,
      Apartment builder(Map<String, dynamic> data)}) {
    print('firebase request: Getting Apartment Stream'); //TODO delete
    final reference = Firestore.instance.collection(path).document(apartmentId);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data));
  }

  Future<Map<String, dynamic>> getDocumentByPath(String path) async {
    print('firebase request: Getting doc by path: ' + path); //TODO delete
    final docReference = await Firestore.instance.document(path).get();
    if (docReference.exists)
      return docReference.data;
    else
      return null;
  }

  Future<void> deleteData({@required String path}) async {
    print('firebase request: Deleting: ' + path); //TODO delete
    final reference = Firestore.instance.document(path);
    await reference.delete();
  }

  Future<void> toggleCheckbox(
      String docPath, String itemId, Map<String, dynamic> newState) async {
    print('firebase request: Changing checkbox status');
    final docRef = Firestore.instance.document(docPath);
    return docRef.setData({itemId: newState}, merge: true);
  }

  Stream<List<T>> singleDocCollectionStream<T>(
      {@required String path,
      @required T builder(Map<String, dynamic> data, String documentId)}) {
    print('firebase request: Single doc collection stream');
    final reference = Firestore.instance.collection(path);
    final snapshots = reference.snapshots();
    return snapshots
        .map((snapshot) => snapshot.documents.map(
              (snapshot) {
                List<T> list = [];
                T t;
                final data = snapshot.data;
                data.forEach((key, value) {
                  value = Map<String, dynamic>.from(value);
                  t = builder(value, key);
                  list.add(t);
                });
                return list;
              },
            ))
        .expand((element) => element);
  }

  Future<void> addFieldToSingleDoc(
      {@required String docPath,
      @required String fieldId,
      @required Map<String, dynamic> field}) async {
    print('firebase request: Adding field to Single doc');

    final reference = Firestore.instance.document(docPath);
    return await reference.setData({fieldId: field}, merge: true);
  }

  Future<void> deleteFieldFromSingleDoc({
    @required String docPath,
    @required String fieldId,
  }) async {
    print('firebase request: Deleting field from Single doc');

    final reference = Firestore.instance.document(docPath);
    return await reference.setData({fieldId: FieldValue.delete()}, merge: true);
  }

  Future<void> deleteMultipleFieldsFromSingleDoc(
      String docPath, List<String> idsToDelete) async {
    print('firebase request: Deleting multiple fields from Single doc');

    final Map<String, FieldValue> deleteMap = {};
    for (String id in idsToDelete) deleteMap[id] = FieldValue.delete();
    final reference = Firestore.instance.document(docPath);
    return await reference.setData(deleteMap, merge: true);
  }
}

// ----------------- Deprecated Code -----------------

// Future<void> deleteInvestmentTransaction(
//   String pathTomonthlySumDoc,
//   String pathToInvestment,
//   String monthYear,
//   int investmentAmount,
// ) {
//   print('Deleting an investment'); //TODO delete
//   final paymentReference = Firestore.instance.document(pathToInvestment);
//   final sumDocRef = Firestore.instance.document(pathTomonthlySumDoc);
//   return Firestore.instance.runTransaction((Transaction tx) async {
//     final docSnapshot = await tx.get(sumDocRef);
//     final prevSumDocData = docSnapshot.data;
//     prevSumDocData[monthYear] = prevSumDocData[monthYear] - investmentAmount;
//     await tx.set(sumDocRef, prevSumDocData);
//     return await paymentReference.delete();
//   });
// }

// Future<void> addInvestmentTransaction(
//     String pathTomonthlySumDoc,
//     String pathToWriteInvestment,
//     String monthYear,
//     int investmentAmount,
//     Map<String, dynamic> investmentData) async {
//   print('Adding an investment'); //TODO delete
//   // assumes sumDoc already exists and contains current month's sum
//   final paymentReference = Firestore.instance.document(pathToWriteInvestment);
//   final sumDocRef = Firestore.instance.document(pathTomonthlySumDoc);
//   return Firestore.instance.runTransaction((Transaction tx) async {
//     final docSnapshot = await tx.get(sumDocRef);
//     final prevSumDocData = docSnapshot.data;
//     if (!prevSumDocData.containsKey(monthYear))
//       prevSumDocData[monthYear] =
//           0; // in case this is the first investment for the given month
//     prevSumDocData[monthYear] = prevSumDocData[monthYear] + investmentAmount;
//     await tx.set(sumDocRef, prevSumDocData);
//     return await tx.set(paymentReference, investmentData);
//   });
// }

// Future<void> initNewMonthInMonthlySumDoc(
//     String pathTomonthlySumDoc, String monthYear) {
//   print('initializing monthly doc'); //TODO delete
//   final sumDocRef = Firestore.instance.document(pathTomonthlySumDoc);
//   return Firestore.instance.runTransaction((Transaction tx) async {
//     final docSnapshot = await tx.get(sumDocRef);
//     if (docSnapshot.exists) {
//       final prevData = docSnapshot.data;
//       prevData[monthYear] = 0;
//       return await tx.set(sumDocRef, prevData);
//     } else
//       return await tx.set(
//         sumDocRef,
//         <String, dynamic>{monthYear: 0},
//       );
//   });
// }

// Future<List<String>> monthsWithTransactions(
//     List<String> months, String path) async {
//   print('Getting months with transactions'); //TODO delete
//   final List<String> output = List<String>();
//   for (String month in months) {
//     final doesMonthHaveTransactions = await Firestore.instance
//         .collection(path + '$month/')
//         .limit(1)
//         .getDocuments();
//     if (doesMonthHaveTransactions.documents.length != 0) output.add(month);
//   }
//   return output;
// }

// Future<String> userPhotoUrl(String path, String uid) async {
//   print('Getting user pgoto url'); //TODO delete
//   final snapshot =
//       await Firestore.instance.collection(path).document(uid).get();
//   final map = snapshot.data;
//   final url = map['photoUrl'];
//   return url;
// }
