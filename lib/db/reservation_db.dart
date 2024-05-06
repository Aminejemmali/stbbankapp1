import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:stbbankapplication1/models/reservation.dart';
import 'package:stbbankapplication1/utils/generate_position.dart';

class ReservationDatabase {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> makeReservation(Reservation reservation) async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      await _database
          .child('reservations/$currentDate')
          .child(reservation.id)
          .set({
        'madeBy': reservation.madeBy,
        'madeAt': reservation.madeAt,
        'operationId': reservation.operationId,
        'bankId': reservation.bankId,
        'position': generatePosition()
      });
    } catch (error) {
      print('Error setting reservation: $error');
    }
  }
}
