import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart' as BadgesPrefix;
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:stbbankapplication1/screens/mapPage/map_page.dart';
import 'package:stbbankapplication1/services/location_provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _notificationCount = 0;

  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    super.initState();
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: loading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Mon Profil'),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(
                            locationInfo: locationInfo,
                          )),
                );
              },
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
    return Container(
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
    );
  }
}
