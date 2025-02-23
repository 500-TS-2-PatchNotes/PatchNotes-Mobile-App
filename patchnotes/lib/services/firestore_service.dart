import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/collections/user.dart';
import '../models/collections/account.dart';
import '../models/collections/wound.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference accountCollection = FirebaseFirestore.instance.collection('accounts');
  final CollectionReference woundCollection = FirebaseFirestore.instance.collection('wounds');

  /// CREATE Operation **
  Future<void> setUserData(String uid, AppUser user, Account account, Wound wound) async {
    WriteBatch batch = _db.batch();

    DocumentReference userRef = userCollection.doc(uid);
    DocumentReference accountRef = accountCollection.doc(uid);
    DocumentReference woundRef = woundCollection.doc(uid);

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

  /// READ Operation **
  Future<AppUser?> getUser(String uid) async {
    final data = await _getDocument(userCollection.doc(uid));
    return data != null ? AppUser.fromMap(data) : null;
  }

  Future<Account?> getAccountInfo(String uid) async {
    final data = await _getDocument(accountCollection.doc(uid));
    return data != null ? Account.fromMap(data) : null;
  }

  Future<Wound?> getWound(String uid) async {
    final data = await _getDocument(woundCollection.doc(uid));
    return data != null ? Wound.fromMap(data) : null;
  }

  /// UPDATE Operation **
  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    await _updateDocument(userCollection.doc(uid), userData);
  }

  Future<void> updateAccount(String uid, Map<String, dynamic> accountData) async {
    await _updateDocument(accountCollection.doc(uid), accountData);
  }

  Future<void> updateWound(String uid, Map<String, dynamic> woundData) async {
    await _updateDocument(woundCollection.doc(uid), woundData);
  }

  /// DELETE Operation **
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

  /// Image Handling for Wounds **
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

  /// Helper Functions (Modified to Return `Map<String, dynamic>` Instead of `T`)**
  Future<Map<String, dynamic>?> _getDocument(DocumentReference docRef) async {
    try {
      DocumentSnapshot doc = await docRef.get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print("Error getting document: $e");
      rethrow;
    }
  }

  Future<void> _updateDocument(DocumentReference docRef, Map<String, dynamic> data) async {
    try {
      await docRef.update(data);
    } catch (e) {
      print("Error updating document: $e");
      rethrow;
    }
  }
}
