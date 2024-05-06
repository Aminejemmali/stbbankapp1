import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String madeBy;
  final Timestamp madeAt;
  final String operationId;
  final double bankId;
  int? position;

  Reservation(
      {required this.id,
      required this.madeBy,
      required this.madeAt,
      required this.operationId,
      required this.bankId,
      this.position});
}
