import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

Future<void> showNotification(dynamic data) async {
  try {
    final seen = data['reviewed'];
    print(data);
    if (seen != null && seen == false) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: data['madeBy'].hashCode,
          channelKey: "cloudsoftware",
          title: "Nouveau Rendez vous",
          body: "Utilisateur a créé un nouveau rendez-vous",
        ),
      );
      // Mark as read
      final databaseRef = FirebaseDatabase.instance.ref().child(
          "reservations/${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(int.parse(data['madeAt'])))}/${data['madeBy']}/");
      databaseRef.update({
        "reviewed": true,
      });
    }
  } catch (e) {
    print(e.toString());
  }
}
