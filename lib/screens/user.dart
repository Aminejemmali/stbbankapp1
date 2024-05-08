import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart' as BadgesPrefix;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:stbbankapplication1/models/operation_type.dart';
import 'package:stbbankapplication1/providers/current_user.dart';
import 'package:stbbankapplication1/screens/mapPage/map_page.dart';
import 'package:stbbankapplication1/services/auth/auth.dart';
import 'package:stbbankapplication1/services/location_provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _notificationCount = 0;
  int munitesLeft = 0;
  bool dataFound = false;
  String operation = "Loading";
  late Timer _timer;
  String code = "";
  String notificationShown = "";
  //Notifaction paramater
  int waitingTime = 10;
  int showNotificationWhen = 8;

  int timestamp = 0;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }

  void listenToRealtimeUpdates() {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final DatabaseReference _databaseReference =
        FirebaseDatabase.instance.ref().child('reservations/$currentDate/');
    try {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        print("listening");
        _databaseReference.onValue.listen((event) {
          final data = event.snapshot.value;
          if (mounted) {
            if (data is Map<Object?, Object?>) {
              data.forEach((key, value) {
                if (value is Map<Object?, Object?> &&
                    value['madeBy'] == FirebaseAuth.instance.currentUser!.uid) {
                  int deadlineTimestamp =
                      int.parse(value['deadlineTime'].toString());
                  DateTime deadlineDateTime =
                      DateTime.fromMillisecondsSinceEpoch(deadlineTimestamp);
                  Duration remainingTime =
                      deadlineDateTime.difference(DateTime.now());
                  OperationType op = operationTypes.firstWhere(
                    (element) => element.id == value['operationId'],
                    orElse: () => OperationType(id: "id", name: "id Not found"),
                  );
                  print("remainingTime ${remainingTime.inMinutes}");
                  if (remainingTime.inMinutes < showNotificationWhen &&
                      notificationShown != value['madeAt'].toString()) {
                    notificationShown = value['madeAt'].toString();
                    _notificationCount++;
                    AwesomeNotifications().createNotification(
                      content: NotificationContent(
                        id: 2,
                        channelKey: "cloudsoftware",
                        title: "Rendez vous",
                        body: "vous reste $showNotificationWhen min",
                      ),
                    );
                  }
                  if (mounted) {
                    updateData(remainingTime, value['code'].toString(), op,
                        deadlineTimestamp);
                  }
                }
              });
            } else {
              print('Unexpected data format: $data');
            }
          }
        });
      });
    } catch (e) {}
  }

  void updateData(Duration remainingTime, String _code,
      OperationType operationType, int time) {
    if (remainingTime.inMinutes < 0) {
      setState(() {
        dataFound = false;
      });
    } else {
      setState(() {
        dataFound = true;
        munitesLeft = remainingTime.inMinutes;
        timestamp = time;
        code = _code;
        operation = operationType.name;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    listenToRealtimeUpdates();
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUserProvider>(context).currentuser;
    return LoadingOverlay(
      isLoading: loading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text('Salut ${currentUser.nom}'),
          centerTitle: true,
          leading: GestureDetector(
              onTap: () async {
                _timer.cancel();
                await UserAuth().signOut(context);
              },
              child: Icon(Icons.logout)),
          actions: [
            IconButton(
              icon: BadgesPrefix.Badge(
                badgeContent: Text(
                  _notificationCount.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                child: Icon(Icons.notifications),
              ),
              onPressed: () {
                //Notification
              },
            )
          ],
        ),
        body: Column(
          children: [
            ViewMapButton(
              onClicked: () async {
                setState(() {
                  loading = !loading;
                });
                bool hasPermission =
                    await LocationProvider().handleLocationPermission(context);
                if (!hasPermission) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Allow location permission")));
                  setState(() {
                    loading = !loading;
                  });
                  return;
                }
                LocationInfo locationInfo =
                    await LocationProvider().getLocation();

                setState(() {
                  loading = !loading;
                });
                _timer.cancel();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(
                            locationInfo: locationInfo,
                          )),
                );
              },
            ),
            dataFound
                ? Card(
                    child: ListTile(
                      leading: GestureDetector(
                          //delete rendez vous
                          onTap: () {
                            final DatabaseReference databaseRef =
                                FirebaseDatabase.instance.ref().child(
                                    "reservations/${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(timestamp))}/${FirebaseAuth.instance.currentUser!.uid}/");

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirm Deletion"),
                                  content:
                                      Text("Are you sure you want to delete?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text("Delete"),
                                      onPressed: () {
                                        databaseRef.remove().then((_) {
                                          if (mounted) {
                                            setState(() {
                                              _timer.cancel();
                                              dataFound = false;
                                            });
                                          }
                                          print("Delete succeeded");
                                          Navigator.of(context).pop();
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
                          child: Icon(Icons.delete)),
                      title: Text(
                        operation,
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text("$munitesLeft min left"),
                      trailing: Text(code),
                    ),
                  )
                : Text(
                    "Vous Rendez vous",
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
          ],
        ),
      ),
    );
  }
}

class ViewMapButton extends StatefulWidget {
  final VoidCallback onClicked;
  const ViewMapButton({super.key, required this.onClicked});

  @override
  State<ViewMapButton> createState() => _ViewMapButtonState();
}

class _ViewMapButtonState extends State<ViewMapButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.white,
                Colors.lightBlue,
                Color.fromARGB(255, 8, 57, 143),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            onPressed: widget.onClicked,
            style: ElevatedButton.styleFrom(
              foregroundColor: Color.fromARGB(49, 33, 182, 202),
              backgroundColor: Color.fromARGB(6, 18, 60, 177),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "View Full Map",
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 253, 250, 250),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
