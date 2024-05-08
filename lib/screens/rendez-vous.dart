import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stbbankapplication1/models/Agence.dart';
import 'package:stbbankapplication1/models/operation_type.dart';
import 'package:stbbankapplication1/models/utilisateur.dart';
import 'package:stbbankapplication1/providers/agence_list.dart';
import 'package:stbbankapplication1/providers/user_list.dart';
import 'package:stbbankapplication1/services/notification/build_notification.dart';
import 'package:stbbankapplication1/utils/generate_position.dart'; // This import is necessary for Material widgets

class RendezVous extends StatefulWidget {
  @override
  _RendezVousState createState() => _RendezVousState();
}

class _RendezVousState extends State<RendezVous> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final DatabaseReference _reservationRef = FirebaseDatabase.instance
      .ref()
      .child("reservations/${DateFormat('yyyy-MM-dd').format(DateTime.now())}");

  @override
  Widget build(BuildContext context) {
    final userList = Provider.of<UserListProvider>(context).users;
    final agenceProvider = Provider.of<AgenceListProvider>(context).agences;
    return StreamBuilder(
      stream: _reservationRef.orderByChild('madeAt').onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var reservationData = (snapshot.data!.snapshot.value ?? {}) as Map;
        var reservations = reservationData.entries.toList();
        reservations.sort((a, b) => int.parse(b.value['madeAt'])
            .compareTo(int.parse(a.value['madeAt'])));

        if (reservations.isNotEmpty) {
          return ListView.builder(
            //reverse: true,
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              var reservation = reservations[index].value;
              showNotification(reservation);

              Utilisateur user = userList.firstWhere(
                (element) => element.uid == reservation['madeBy'],
              );
              final operation = operationTypes.firstWhere(
                  (element) => element.id == reservation['operationId'],
                  orElse: () =>
                      OperationType(id: "defaultId", name: "defaultName"));
              final bank = agenceProvider.firstWhere(
                  (element) => element.id == reservation['bankId'].toString(),
                  orElse: () => Agence(
                        id: "id",
                        bank_id: "bank_id",
                        name: "name",
                        locationBranch:
                            LocationBranch(latitude: 0, longitude: 0),
                      ));
              return GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Deletion"),
                        content: const Text("Are you sure you want to delete?"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("Delete"),
                            onPressed: () {
                              final databaseRef = FirebaseDatabase.instance
                                  .ref()
                                  .child(
                                      "reservations/${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(int.parse(reservation['madeAt'].toString())))}/${reservation['madeBy'].toString()}/");

                              databaseRef.remove().then((_) {
                                print("Delete succeeded");
                                Navigator.of(context).pop();
                                setState(() {});
                              }).catchError((error) {
                                print("Delete failed: $error");
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(
                    "${bank.name}: ${operation.name}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Heure Limit:${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(reservation['deadlineTime'])))}",
                        style: TextStyle(
                            color: DateTime.now().millisecondsSinceEpoch <
                                    int.parse(reservation['deadlineTime'])
                                ? Colors.green
                                : Colors.red),
                      ),
                      Text("${user.nom} ${user.prenom}")
                    ],
                  ),
                  trailing: Text(
                    reservation['code'] ?? "Unkown",
                    style: GoogleFonts.poppins(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              );
            },
          );
        } else {
          return Center(
            child: Text(
              "Aucun Rendez vous maintenant",
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
        }
      },
    );
  }
}
