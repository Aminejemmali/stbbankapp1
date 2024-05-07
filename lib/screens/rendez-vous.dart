import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stbbankapplication1/models/utilisateur.dart';
import 'package:stbbankapplication1/providers/user_list.dart';
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

    print(generatePosition());
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

        print(reservations);
        return ListView.builder(
          //reverse: true,
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            var reservation = reservations[index].value;

            //  print(reservation);
            Utilisateur user = userList.firstWhere(
              (element) => element.uid == reservation['madeBy'],
            );
            return ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text(reservation['operationId']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('MMM-dd HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(reservation['madeAt'])))),
                  Text("${user.nom} ${user.prenom}")
                ],
              ),
              trailing: Text(
                reservation['position'],
                style: GoogleFonts.poppins(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            );
          },
        );
      },
    );
  }
}
