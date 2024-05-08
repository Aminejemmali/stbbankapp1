import 'package:firebase_database/firebase_database.dart';

class Reservation {
  final String id;
  final String madeBy;
  final String madeAt;
  final String operationId;
  final String bankId;
  final String deadlineTime;
  String? code;
  bool reviewed;

  Reservation({
    required this.id,
    required this.madeBy,
    required this.madeAt,
    required this.operationId,
    required this.bankId,
    required this.reviewed,
    required this.deadlineTime,
    this.code,
  });

  factory Reservation.fromSnapshot(DataSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.value as Map<String, dynamic>;
    return Reservation(
      id: snapshot.key ?? '',
      madeBy: data['madeBy'] ?? '',
      madeAt: data['madeAt'] ?? '',
      operationId: data['operationId'] ?? '',
      bankId: data['bankId'] ?? '',
      deadlineTime: data['deadlineTime'] ?? '',
      code: data['code'] ?? '',
      reviewed: data['reviewed'] ?? false,
    );
  }
}
