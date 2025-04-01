import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/collections/user.dart';
import '../models/collections/account.dart';
import '../models/collections/wound.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  DocumentReference getUserDoc(String uid) => userCollection.doc(uid);
  DocumentReference getAccountDoc(String uid) =>
      getUserDoc(uid).collection('account').doc('settings');
  DocumentReference getWoundDoc(String uid) =>
      getUserDoc(uid).collection('wound_data').doc('info');

  /// CREATE
  Future<void> setUserData(
      String uid, AppUser user, Account account, Wound wound) async {
    WriteBatch batch = _db.batch();

    final userRef = getUserDoc(uid);
    final accountRef = getAccountDoc(uid);
    final woundRef = getWoundDoc(uid);

    try {
      batch.set(userRef, user.toFirestore(), SetOptions(merge: true));
      batch.set(accountRef, account.toFirestore(), SetOptions(merge: true));
      batch.set(woundRef, wound.toFirestore(), SetOptions(merge: true));

      await batch.commit();
      print("User data initialized for UID: $uid");
    } catch (e) {
      print("Failed to set user data: $e");
      rethrow;
    }
  }

  /// READ
  Future<AppUser?> getUser(String uid) async {
    final data = await _getDocument(getUserDoc(uid));
    return data != null ? AppUser.fromMap(data) : null;
  }

  Future<Account?> getAccountInfo(String uid) async {
    final data = await _getDocument(getAccountDoc(uid));
    return data != null ? Account.fromMap(data) : null;
  }

  Future<Wound?> getWound(String uid) async {
    final data = await _getDocument(getWoundDoc(uid));
    return data != null ? Wound.fromMap(data) : null;
  }

  /// UPDATE
  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    await _updateDocument(getUserDoc(uid), userData);
  }

  Future<void> updateAccount(
      String uid, Map<String, dynamic> accountData) async {
    await _updateDocument(getAccountDoc(uid), accountData);
  }

  Future<void> updateWound(String uid, Map<String, dynamic> woundData) async {
    await _updateDocument(getWoundDoc(uid), woundData);
  }

  Future<void> updateWoundImagesFromLatest(String uid) async {
    try {
      final woundDataRef =
          _db.collection('users').doc(uid).collection('wound_data');

      // Get latest image doc (excluding 'info')
      final snapshot = await woundDataRef
          .where(FieldPath.documentId, isNotEqualTo: 'info')
          .orderBy('analyze_time', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return;

      final latestUrl = snapshot.docs.first.data()['URL'] as String?;

      if (latestUrl == null) return;

      // Get current woundImages
      final infoRef = getWoundDoc(uid);
      final infoSnap = await infoRef.get();
      final data = infoSnap.data() as Map<String, dynamic>? ?? {};
      final currentImages = List<String>.from(data['woundImages'] ?? []);

      // Treat as a queue: prepend and trim to 9
      final updated = [latestUrl, ...currentImages].take(9).toList();

      await infoRef.update({'woundImages': updated});
    } catch (e) {
      print("Failed to update woundImages from latest: $e");
      rethrow;
    }
  }

  Future<void> updateCurrentLvlFromLatest(String uid) async {
    final woundDataRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wound_data');

    // Step 1: Get the 9 most recent wound documents (excluding 'info')
    final snapshot = await woundDataRef
        .where(FieldPath.documentId, isNotEqualTo: 'info')
        .orderBy('imageTimestamp', descending: true)
        .limit(9)
        .get();

    if (snapshot.docs.isEmpty) return;

    // Step 2: Extract levels from the latest docs
    final levels = snapshot.docs
        .map((doc) => doc.data()['level'])
        .where((level) => level != null)
        .cast<int>()
        .toList();

    final latestLevel = levels.first;

    // Step 3: Update the info doc
    final infoRef = woundDataRef.doc('info');
    await infoRef.set({
      'currentLvl': latestLevel,
      'recentLevels': levels,
      'lastSynced': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

  }

  /// DELETE
  Future<void> deleteAllUserData(String uid) async {
    try {
      final userDocRef = getUserDoc(uid);
      final woundDataRef = userDocRef.collection('wound_data');

      final woundDataSnapshot = await woundDataRef.get();
      for (final doc in woundDataSnapshot.docs) {
        await doc.reference.delete();
      }

      await getAccountDoc(uid).delete();

      await userDocRef.delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addWoundImage(String uid, String imageUrl) async {
    try {
      final woundDoc = getWoundDoc(uid);
      final snapshot = await woundDoc.get();

      List<String> currentImages = [];

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        currentImages = List<String>.from(data['woundImages'] ?? []);
      }

      if (currentImages.length >= 9) {
        currentImages.removeAt(0);
      }

      currentImages.add(imageUrl);

      await woundDoc
          .set({'woundImages': currentImages}, SetOptions(merge: true));
    } catch (e) {
      print("Failed to add wound image: $e");
      rethrow;
    }
  }

  Future<void> removeWoundImage(String uid, String imageUrl) async {
    try {
      await getWoundDoc(uid).update({
        "woundImages": FieldValue.arrayRemove([imageUrl])
      });
    } catch (e) {
      print("Error removing wound image: $e");
      rethrow;
    }
  }

  /// Helpers
  Future<Map<String, dynamic>?> _getDocument(DocumentReference docRef) async {
    try {
      DocumentSnapshot doc = await docRef.get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print("Error reading document: $e");
      rethrow;
    }
  }

  Future<void> _updateDocument(
      DocumentReference docRef, Map<String, dynamic> data) async {
    try {
      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      print("Error updating document: $e");
      rethrow;
    }
  }
}
