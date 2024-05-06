import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stbbankapplication1/models/Agence.dart';
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
  Future<void> readJson(double distance) async {
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
      radius: 30 * 1000,
      fillColor: Colors.blue.withOpacity(0.3), // Blue color with opacity
      strokeWidth: 0, // No border
    ));
  }

  @override
  void initState() {
    super.initState();
    readJson(30);

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
              infoWindow: InfoWindow(
                  title: /*(polylines.isEmpty)?"List is Empty":*/
                      "${e.name}"),
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Card(
                        child: ListTile(
                          title: Text(e.name),
                          subtitle: Text(e.id),
                          // Add more info fields as needed
                        ),
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
    LocationInfo currentLocation = widget.locationInfo;
    return MaterialApp(
        home: Scaffold(
      body: GoogleMap(
        markers: getMarkers(),
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
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
    ));
  }
}
