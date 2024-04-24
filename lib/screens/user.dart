import 'dart:collection';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart' as BadgesPrefix;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stbbankapplication1/screens/map_Page.dart';

class NotificationData {
  final int id;
  final String title;
  final String body;

  NotificationData({required this.id, required this.title, required this.body});
}

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  int _notificationCount = 0;
  List<Map<String, dynamic>> data = [];
  List<dynamic> agenciesData = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add the following variables for Google Maps
  Set<Marker> markers = HashSet<Marker>();
  GoogleMapController? mapController;

  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Initialize Awesome Notifications
    _initializeNotifications();

    // Fetch data from the API
    fetchData();

    // Initialize notification count
    _getCurrentUser();

    // Example: Fetch data from Firestore
    _fetchDataFromFirestore();
    super.initState();
  }

  Future<void> _fetchDataFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> data =
          await _firestore.collection('users').get();

      // Process your data here
      for (QueryDocumentSnapshot<Map<String, dynamic>> document in data.docs) {
        print('Document ID: ${document.id}, Data: ${document.data()}');
      }
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      print('Current user: ${_currentUser!.displayName}');
    }
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'basic_notifications',
          channelDescription: 'Test notification channel',
        ),
      ],
      debug: true,
    );
  }

  Future<void> fetchData() async {
    try {
      agenciesData = [
        {
          "id": "000",
          "bank_id": "10",
          "name": "AV.H.THAMEUR TUNIS",
          "latitude": "36.801304",
          "longitude": "10.178042",
          "adressBranch": {
            "line_1": "",
            "line_2": "",
            "line_3": "",
            "city": "TUNIS",
            "county": "TUNIS",
            "state": "TUNIS",
            "postcode": "1000      ",
            "country_code": null
          },
          "branchrouting": {"scheme": "OBP", "address": ""},
          "is_accessible": "true",
          "accessibleFeatures":
              "wheelchair, atm usuable by the visually impaired",
          "branch_type": "Full service store",
          "location": "short walk to the lake from here",
          "phone_number": ""
        },
        {
          "id": "001",
          "bank_id": "10",
          "name": "R.AL JAZIRA TUNIS",
          "latitude": "36.7960989",
          "longitude": "10.175778",
          "adressBranch": {
            "line_1": "",
            "line_2": "",
            "line_3": "",
            "city": "TUNIS",
            "county": "TUNIS",
            "state": "TUNIS",
            "postcode": "1000      ",
            "country_code": null
          },
          "branchrouting": {"scheme": "OBP", "address": ""},
          "is_accessible": "true",
          "accessibleFeatures":
              "wheelchair, atm usuable by the visually impaired",
          "branch_type": "Full service store",
          "location": "short walk to the lake from here",
          "phone_number": ""
        },
        {
          "id": "002",
          "bank_id": "10",
          "name": "SOUSSE",
          "latitude": "35.830139",
          "longitude": "10.6403229999999",
          "adressBranch": {
            "line_1": "",
            "line_2": "",
            "line_3": "",
            "city": "SOUSSE",
            "county": "SOUSSE",
            "state": "SOUSSE",
            "postcode": "4000      ",
            "country_code": null
          },
          "branchrouting": {"scheme": "OBP", "address": ""},
          "is_accessible": "true",
          "accessibleFeatures":
              "wheelchair, atm usuable by the visually impaired",
          "branch_type": "Full service store",
          "location": "short walk to the lake from here",
          "phone_number": ""
        },
        {
          "id": "003",
          "bank_id": "10",
          "name": "MAHDIA",
          "latitude": "35.5032209496669",
          "longitude": "11.068816781044",
          "adressBranch": {
            "line_1": "",
            "line_2": "",
            "line_3": "",
            "city": "MAHDIA",
            "county": "MAHDIA",
            "state": "MAHDIA",
            "postcode": "5100      ",
            "country_code": null
          },
          "branchrouting": {"scheme": "OBP", "address": ""},
          "is_accessible": "true",
          "accessibleFeatures":
              "wheelchair, atm usuable by the visually impaired",
          "branch_type": "Full service store",
          "location": "short walk to the lake from here",
          "phone_number": ""
        }
      ];
      _notificationCount = agenciesData.length; // Update notification count
      _updateMarkers(); // Update map markers

      /*   final response = await http
          .get(Uri.parse('https://nourhouili.github.io/stblocation/db.json'));

      if (response.statusCode == 200) {
        setState(() {
          agenciesData = List<dynamic>.from(json.decode(response.body));
        
          _notificationCount = agenciesData.length; // Update notification count
          _updateMarkers(); // Update map markers
        });
      } else {
        throw Exception('Failed to load data');
      } */
    } catch (e) {
      print('Error fetching data: $e');
      // Handle the error as needed
    }
  }

  // Add the following method to update the map markers
  void _updateMarkers() {
    markers.clear();
    for (var agency in agenciesData) {
      double lat = double.parse(agency['latitude']);
      double lng = double.parse(agency['longitude']);
      markers.add(Marker(
        markerId: MarkerId(agency['name']),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: agency['name'],
          snippet: agency['location'],
        ),
      ));
    }
  }

  // Add the following method to handle map creation
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    print("Data length: ${data.length}");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Mon Profil'),
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
              //Navigator.of(context).pushReplacementNamed('notificationsList');
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildMapButton(context),
          /*child: agenciesData.isEmpty
                ? CircularProgressIndicator()
                : GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        double.parse(agenciesData[0]['latitude']),
                        double.parse(agenciesData[0]['longitude']),
                      ),
                      zoom: 10.0,
                    ),
                    markers: markers,
                  ),*/

          /*Expanded(
            child: ListView.builder(
              itemCount: agenciesData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(agenciesData[index]['name']),
                  subtitle: Text(agenciesData[index]['location']),
                );
              },
            ),
          ),*/
        ],
      ),
    );
  }
}

Widget _buildMapButton(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
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
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Color.fromARGB(49, 33, 182, 202), backgroundColor: Color.fromARGB(6, 18, 60, 177),
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
