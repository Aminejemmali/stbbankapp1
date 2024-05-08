import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stbbankapplication1/db/reservation_db.dart';
import 'package:stbbankapplication1/models/Agence.dart';
import 'package:stbbankapplication1/models/operation_type.dart';
import 'package:stbbankapplication1/models/reservation.dart';
import 'package:stbbankapplication1/screens/MapScreen.dart';
import 'package:stbbankapplication1/services/location_provider.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget(
      {super.key, required this.agence, required this.locationInfo});

  final Agence agence;
  final LocationInfo locationInfo;

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  OperationType? selectedOperation;
  int _rendezVousCount = 0;
  bool dataLoaded = false;
  void getRendezVousCount() {
    final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final _query =
        FirebaseDatabase.instance.ref().child('reservations/$currentDate');

    _query.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map<Object?, Object?>) {
        int counter = 0;
        int serverTimestamps = Timestamp.now().millisecondsSinceEpoch;
        data.forEach((key, value) {
          if (value is Map<Object?, Object?> &&
              value['bankId'].toString() == widget.agence.id &&
              // check if reservation not expired
              serverTimestamps < int.parse(value['deadlineTime'].toString())) {
            counter++;
          }
        });
        setState(() {
          _rendezVousCount = counter;
          dataLoaded = true;
        });
      } else {
        // Handle the case where the child with the current date does not exist
        setState(() {
          _rendezVousCount = 0;
          dataLoaded = true;
        });
      }
    });
  }

  // void getRendezVousCout() {
  //   final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //   final _query =
  //       FirebaseDatabase.instance.ref().child('reservations/$currentDate');

  //   _query.onValue.listen((event) {
  //     final data = event.snapshot.value;
  //     if (data is Map<Object?, Object?>) {
  //       int counter = 0;
  //       int serverTimestamps = Timestamp.now().millisecondsSinceEpoch;
  //       data.forEach((key, value) {
  //         if (value is Map<Object?, Object?> &&
  //             value['bankId'].toString() == widget.agence.id &&
  //             // check if reservation not expired
  //             serverTimestamps < int.parse(value['deadlineTime'].toString())) {
  //           counter++;
  //         }
  //       });
  //       setState(() {
  //         _rendezVousCount = counter;
  //         dataLoaded = true;
  //       });
  //     }
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRendezVousCount();
  }

  @override
  Widget build(BuildContext context) {
    int _waitingTime = 10;
    int waitingTime = _rendezVousCount * _waitingTime;
    DateTime now = DateTime.now();
    DateTime deadlineTime =
        now.add(Duration(minutes: waitingTime + _waitingTime));
    bool loading = false;
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance),
            title: Text(widget.agence.name),
            subtitle: Text("# ${widget.agence.id}"),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapScreen(
                            currentLocation: widget.locationInfo,
                            lat: widget.agence.locationBranch.latitude,
                            long: widget.agence.locationBranch.longitude)));
                // polylineCoordinates[1].longitude != e.locationBranch.latitude;
                // polylineCoordinates[1].longitude != e.locationBranch.longitude;
              },
              child: const Text('View route'),
            ),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: dataLoaded ? "${_rendezVousCount} " : "...",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: "Rendez-vous avant toi",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Temps d'attente: ",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: dataLoaded ? "$waitingTime minutes" : "... minutes",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Heure limite(pour vous): ",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: dataLoaded
                    ? DateFormat('HH:mm').format(deadlineTime)
                    : "Loading...",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Text("Operation"),
        Center(
          child: DropdownButton<OperationType>(
            hint: Text(selectedOperation != null
                ? selectedOperation!.name
                : 'Select an operation type'),
            value: null,
            onChanged: (OperationType? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedOperation = newValue;
                });
              }
            },
            items: operationTypes.map<DropdownMenuItem<OperationType>>(
                (OperationType operationType) {
              return DropdownMenuItem<OperationType>(
                value: operationType,
                child: Text(operationType.name),
              );
            }).toList(),
          ),
        ),
        if (dataLoaded)
          ElevatedButton(
              onPressed: () async {
                if (selectedOperation == null) {
                  _showMessage(
                      context, "veuillez sélectionner un type d'opération");
                  return;
                }
                setState(() {
                  loading = !loading;
                });

                await ReservationDatabase().makeReservation(Reservation(
                    id: FirebaseAuth.instance.currentUser!.uid,
                    madeBy: FirebaseAuth.instance.currentUser!.uid,
                    madeAt: Timestamp.now().millisecondsSinceEpoch.toString(),
                    reviewed: false,
                    operationId: selectedOperation!.id,
                    deadlineTime:
                        deadlineTime.millisecondsSinceEpoch.toString(),
                    bankId: widget.agence.id));
                setState(() {
                  loading = !loading;
                });
                _showMessage(context, "Rendez vous envoi");
              },
              child: const Text("Rendez vous")),
      ],
    );
  }
}

void _showMessage(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
