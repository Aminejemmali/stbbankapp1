import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stbbankapplication1/db/reservation_db.dart';
import 'package:stbbankapplication1/models/Agence.dart';
import 'package:stbbankapplication1/models/reservation.dart';
import 'package:stbbankapplication1/services/location_provider.dart';
import 'package:stbbankapplication1/utils/distance.dart';

class MapPage extends StatefulWidget {
  final LocationInfo locationInfo;
  const MapPage({super.key, required this.locationInfo});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  PolylinePoints polylinePoints = PolylinePoints();
  List<Agence> agences = [];
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  double distance = 30;
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/agence.json');
    final data = await json.decode(response);
    setState(() {
      agences = (data["items"] as List<dynamic>)
          .map((e) => Agence.fromJson(e))
          .where((element) =>
              calculateDistance(
                  element.locationBranch.latitude,
                  element.locationBranch.longitude,
                  widget.locationInfo.latitude,
                  widget.locationInfo.longitude) <
              distance)
          .toList();
    });
  }

  void calculateCircle() {
    circles.add(Circle(
      circleId: CircleId('circle'),
      center:
          LatLng(widget.locationInfo.latitude, widget.locationInfo.longitude),
      radius: distance * 1000,
      fillColor: Colors.blue.withOpacity(0.3),
      strokeWidth: 0,
    ));
  }

  @override
  void initState() {
    super.initState();
    readJson();

    setCustomMarker();
    calculateCircle();
    //getPolyPoint();
    //_getPolyline();
  }

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  void setCustomMarker() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/img/gps.png")
        .then((icon) => {sourceIcon = icon});
  }

  Set<Marker> getMarkers() {
    markers = agences
        .map((e) => Marker(
              markerId: MarkerId(e.id),
              infoWindow: InfoWindow(title: e.name),
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      // ! Temps attende
                      // ! rendé vous 9ablo
                      return Column(
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                await ReservationDatabase().makeReservation(
                                    Reservation(
                                        id: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        madeBy: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        madeAt: Timestamp.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        reviewed: false,
                                        operationId: "account",
                                        bankId: e.bank_id));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Render vos faite")));
                              },
                              child: Text("Rendez vous")),
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.balance),
                              title: Text(e.name),
                              subtitle: Text(e.id),
                              trailing: ElevatedButton(
                                onPressed: () {},
                                child: const Text('View route'),
                              ),
                            ),
                          ),
                        ],
                      );
                    });
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => MapScreen(
                //             lat: e.locationBranch.latitude,
                //             long: e.locationBranch.longitude)));
                //polylineCoordinates[1].longitude!=e.locationBranch.latitude;
                //polylineCoordinates[1].longitude!=e.locationBranch.longitude;
              },
              position:
                  LatLng(e.locationBranch.latitude, e.locationBranch.longitude),
            ))
        .toSet();

    markers.add(Marker(
        markerId: MarkerId("sourceLocation"),
        position:
            LatLng(widget.locationInfo.latitude, widget.locationInfo.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(90)));
    return markers;
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    LocationInfo currentLocation = widget.locationInfo;
    double h = MediaQuery.of(context).size.height;
    return MaterialApp(
        home: Scaffold(
      body: Column(
        children: [
          Container(
            height: h * 0.9,
            child: GoogleMap(
              markers: getMarkers(),
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(currentLocation.latitude, currentLocation.longitude),
                zoom: 14.5,
              ),
              circles: circles,
              //polylines: Set<Polyline>.of(polylines.values),
              myLocationEnabled: true,
              //tiltGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              //cameraTargetBounds: CameraTargetBounds.unbounded,
            ),
          ),
          Slider(
            value: distance,
            min: 10,
            max: 100,
            divisions: 9,
            label: 'Distance: $distance km',
            onChanged: (value) {
              setState(() {
                distance = value;
                circles.clear();
                calculateCircle();
                readJson();
              });
            },
          ),
        ],
      ),
    ));
  }
}
