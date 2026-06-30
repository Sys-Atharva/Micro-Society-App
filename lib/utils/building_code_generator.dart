import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuildingCodeGenerator {
  static const String _prefix = 'BLDG-';
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static final _random = Random.secure();

  static String _generate() {
    final code = List.generate(
      4,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
    return '$_prefix$code';
  }

  static Future<String> generateUnique() async {
    for (int i = 0; i < 10; i++) {
      final code = _generate();
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('buildingCode', isEqualTo: code)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) return code;
    }
    throw Exception('Failed to generate unique building code');
  }
}
