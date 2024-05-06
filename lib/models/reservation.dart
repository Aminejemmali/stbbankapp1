import 'package:firebase_database/firebase_database.dart';

class Reservation {
  final String id;
  final String madeBy;
  final String madeAt;
  final String operationId;
  final String bankId;
  String? position;
  bool reviewed;

  Reservation({
    required this.id,
    required this.madeBy,
    required this.madeAt,
    required this.operationId,
    required this.bankId,
    required this.reviewed,
    this.position,
  });

  factory Reservation.fromSnapshot(DataSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.value as Map<String, dynamic>;
    return Reservation(
      id: snapshot.key ?? '',
      madeBy: data['madeBy'] ?? '',
      madeAt: data['madeAt'] ?? '',
      operationId: data['operationId'] ?? '',
      bankId: data['bankId'] ?? '',
      position: data['position'] ?? '',
      reviewed: data['reviewed'] ?? false,
    );
  }
}
