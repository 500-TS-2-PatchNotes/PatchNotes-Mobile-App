import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/collections/user.dart';
import '../models/collections/account.dart';
import '../models/collections/wound.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references with Firestore converters
  final CollectionReference<AppUser> userCollection = FirebaseFirestore.instance
      .collection('users')
      .withConverter<AppUser>(
        fromFirestore: (snapshot, _) => AppUser.fromFirestore(snapshot, null),
        toFirestore: (user, _) => user.toFirestore(),
      );

  final CollectionReference<Account> accountCollection =
      FirebaseFirestore.instance.collection('accounts').withConverter<Account>(
            fromFirestore: (snapshot, _) =>
                Account.fromFirestore(snapshot, null),
            toFirestore: (account, _) => account.toFirestore(),
          );

  final CollectionReference<Wound> woundCollection =
      FirebaseFirestore.instance.collection('wounds').withConverter<Wound>(
            fromFirestore: (snapshot, _) => Wound.fromFirestore(snapshot, null),
            toFirestore: (wound, _) => wound.toFirestore(),
          );

  /// CREATE Operation
  Future<void> setUserData(String uid, AppUser user, Account account, Wound wound) async {
    WriteBatch batch = _db.batch();

    DocumentReference userRef = _db.collection("users").doc(uid);
    DocumentReference accountRef = _db.collection("accounts").doc(uid);
    DocumentReference woundRef = _db.collection("wounds").doc(uid);

    try {
      print("Starting Firestore batch write for UID: $uid");

      batch.set(userRef, user.toFirestore(), SetOptions(merge: true));
      batch.set(accountRef, account.toFirestore(), SetOptions(merge: true));
      batch.set(woundRef, wound.toFirestore(), SetOptions(merge: true));

      await batch.commit();
      print("Firestore batch write successful for UID: $uid");
    } catch (e) {
      print("Firestore batch write failed for UID: $uid -> $e");
      rethrow; 
    }
  }

  /// READ Operations
  Future<AppUser?> getUser(String uid) async => _getDocument(userCollection.doc(uid));
  Future<Account?> getAccountInfo(String uid) async => _getDocument(accountCollection.doc(uid));
  Future<Wound?> getWound(String uid) async => _getDocument(woundCollection.doc(uid));

  /// UPDATE Operations
  Future<void> updateUser(String uid, Map<String, dynamic> userData) async =>
      _updateDocument(userCollection.doc(uid), userData);

  Future<void> updateAccount(String uid, Map<String, dynamic> accountData) async =>
      _updateDocument(accountCollection.doc(uid), accountData);

  Future<void> updateWound(String uid, Map<String, dynamic> woundData) async =>
      _updateDocument(woundCollection.doc(uid), woundData);

  /// DELETE Operation
  Future<void> deleteAllUserData(String uid) async {
    WriteBatch batch = _db.batch();

    batch.delete(userCollection.doc(uid));
    batch.delete(accountCollection.doc(uid));
    batch.delete(woundCollection.doc(uid));

    try {
      await batch.commit();
      print("User data successfully deleted.");
    } catch (e) {
      print("Error deleting user data: $e");
      rethrow;
    }
  }

  /// Image Handling for Wounds
  Future<void> addWoundImage(String uid, String imageUrl) async {
    try {
      await woundCollection.doc(uid).update({
        "woundImages": FieldValue.arrayUnion([imageUrl])
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeWoundImage(String uid, String imageUrl) async {
    try {
      await woundCollection.doc(uid).update({
        "woundImages": FieldValue.arrayRemove([imageUrl])
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Batch Update for User and Account
  Future<void> batchUpdateUserAndAccount(String uid, Map<String, dynamic> userData, Map<String, dynamic> accountData) async {
    WriteBatch batch = _db.batch();

    batch.update(userCollection.doc(uid), userData);
    batch.update(accountCollection.doc(uid), accountData);

    try {
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Transaction Update for User and Account
  Future<void> updateUserAndAccountTransaction(String uid, Map<String, dynamic> userData, Map<String, dynamic> accountData) async {
    return _db.runTransaction((transaction) async {
      DocumentReference userRef = userCollection.doc(uid);
      DocumentReference accountRef = accountCollection.doc(uid);

      DocumentSnapshot userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception("This user does not exist!");
      }

      transaction.update(userRef, userData);
      transaction.update(accountRef, accountData);
    }).catchError((error) {
      throw error;
    });
  }

  // Helper Functions
  Future<T?> _getDocument<T>(DocumentReference<T> docRef) async {
    try {
      DocumentSnapshot<T> doc = await docRef.get();
      return doc.data();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateDocument<T>(DocumentReference<T> docRef, Map<String, dynamic> data) async {
    try {
      await docRef.update(data);
    } catch (e) {
      rethrow;
    }
  }
}
