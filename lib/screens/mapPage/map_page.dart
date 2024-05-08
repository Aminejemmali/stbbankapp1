import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:stbbankapplication1/models/Agence.dart';
import 'package:stbbankapplication1/screens/mapPage/widgets/bottom_sheet.dart';
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
  double distance = 10;
  int rendezVousCount = -1;
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
              onTap: () async {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return BottomSheetWidget(
                          locationInfo: widget.locationInfo,
                          // rendezVousCount: rendezVousCount,
                          agence: e);
                    });
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
