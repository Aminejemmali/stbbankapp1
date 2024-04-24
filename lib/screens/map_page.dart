import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:stbbankapplication1/models/Agence.dart';
import 'package:stbbankapplication1/screens/MapScreen.dart';



class MapPage extends StatefulWidget {
  const MapPage({Key? key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  String googleAPiKey = "AIzaSyBn9NQtMUKL6_iYfLiAW6l8Y1AFtpSxb0Q";
  PolylinePoints polylinePoints = PolylinePoints();
  List<Agence> agences = [];
  Set<Marker> markers = {};
  LocationData? currentLocation;
  //Map<PolylineId, Polyline> polylines = {};
  void getCurrentLocation() async {
    Location location = Location();

    try {
      // Get the current location
      LocationData? locationData = await location.getLocation();

      // Update the currentLocation variable if locationData is not null
      if (locationData != null) {
        setState(() {
          currentLocation = locationData;
        });
      }
    } catch (e) {
      // Handle any errors that occur while getting the location
      print('Error getting location: $e');
    }
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/agence.json');
    final data = await json.decode(response);
    setState(() {
      agences = (data["items"] as List<dynamic>)
          .map((e) => Agence.fromJson(e))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
    getCurrentLocation();
    setCustomMarker();
    //getPolyPoint();
    //_getPolyline();
  }
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  void setCustomMarker(){
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/img/blue_pin.png"
    ).then((icon) => {
      sourceIcon = icon
    });
  }
  Set<Marker> getMarkers()  {
    markers = agences
        .map((e) => Marker(
              markerId: MarkerId(e.id),
              infoWindow: InfoWindow(
                title:/*(polylines.isEmpty)?"List is Empty":*/"Voulez vous choisir cette agence ?"
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(lat:e.locationBranch.latitude,long:  e.locationBranch.longitude)));
                //polylineCoordinates[1].longitude!=e.locationBranch.latitude;
                //polylineCoordinates[1].longitude!=e.locationBranch.longitude;
              },
              position:
                  LatLng(e.locationBranch.latitude, e.locationBranch.longitude),
            ))
        .toSet();

    markers.add(Marker(
        markerId: MarkerId("sourceLocation"),

      position: LatLng(currentLocation!.latitude!,currentLocation!.longitude!),
     // icon: BitmapDescriptor.defaultMarkerWithHue(90)
    ));
    /*markers.add(Marker(
        markerId: MarkerId("source"),
        position: LatLng(36.819876, 10.181961),
        icon: sourceIcon
    ));*/

    return markers;
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  final LatLng center = const LatLng(36.801304, 10.178042);




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: currentLocation == null ? Center(child: Text("Loading")):GoogleMap(
        markers: getMarkers(),
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation!.latitude!,currentLocation!.longitude!),
          zoom: 14.5,
        ),
        //polylines: Set<Polyline>.of(polylines.values),
        //myLocationEnabled: true,
        //tiltGesturesEnabled: true,
        compassEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        //cameraTargetBounds: CameraTargetBounds.unbounded,
      ),
    ));
  }
}

