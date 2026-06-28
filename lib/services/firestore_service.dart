import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String docId,
  }) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      return data;
    }
    return null;
  }

  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  Future<List<Map<String, dynamic>>> getDocuments({
    required String collection,
    String? field,
    dynamic isEqualTo,
    String? orderByField,
    bool descending = false,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection(collection).withConverter<Map<String, dynamic>>(
              fromFirestore: (snapshot, _) => snapshot.data()!,
              toFirestore: (data, _) => data,
            );

    if (field != null && isEqualTo != null) {
      query = query.where(field, isEqualTo: isEqualTo);
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    final snapshot = await query.get();
    final results = <Map<String, dynamic>>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      results.add(data);
    }
    return results;
  }

  Stream<List<Map<String, dynamic>>> streamDocuments({
    required String collection,
    String? field,
    dynamic isEqualTo,
    String? orderByField,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(collection).withConverter<Map<String, dynamic>>(
              fromFirestore: (snapshot, _) => snapshot.data()!,
              toFirestore: (data, _) => data,
            );

    if (field != null && isEqualTo != null) {
      query = query.where(field, isEqualTo: isEqualTo);
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    return query.snapshots().map((snapshot) {
      final results = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        results.add(data);
      }
      return results;
    });
  }
}
