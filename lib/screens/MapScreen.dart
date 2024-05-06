// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

// class MapScreen extends StatefulWidget {
//   final double lat;
//   final double long;

//   const MapScreen({Key? key, required this.lat, required this.long})
//       : super(key: key);
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController mapController;
//   double _originLatitude = 36.846677, _originLongitude = 10.207745;

//   ///double _destLatitude = 36.819837, _destLongitude = 10.181969;
//   // double _originLatitude = 26.48424, _originLongitude = 50.04551;
//   // double _destLatitude = 26.46423, _destLongitude = 50.06358;
//   Map<MarkerId, Marker> markers = {};
//   Map<PolylineId, Polyline> polylines = {};
//   List<LatLng> polylineCoordinates = [];
//   PolylinePoints polylinePoints = PolylinePoints();
//   String googleAPiKey = "AIzaSyBn9NQtMUKL6_iYfLiAW6l8Y1AFtpSxb0Q";

//   /// Teting Current Location
//   LocationData? currentLocation;
//   //Map<PolylineId, Polyline> polylines = {};
//   void getCurrentLocation() async {
//     Location location = Location();

//     try {
//       // Get the current location
//       LocationData? locationData = await location.getLocation();

//       // Update the currentLocation variable if locationData is not null
//       if (locationData != null) {
//         setState(() {
//           currentLocation = locationData;
//         });
//         _addMarker(
//             LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
//             "origin",
//             BitmapDescriptor.defaultMarkerWithHue(90));
//         _getPolyline();
//       }
//     } catch (e) {
//       // Handle any errors that occur while getting the location
//       print('Error getting location: $e');
//     }
//   }

//   /// End Current Location
//   @override
//   void initState() {
//     super.initState();
//     getCurrentLocation();

//     /// origin marker

//     /*_addMarker(LatLng(_originLatitude, _originLongitude), "origin",
//         BitmapDescriptor.defaultMarker);*/

//     /// destination marker
//     _addMarker(LatLng(widget.lat, widget.long), "destination",
//         BitmapDescriptor.defaultMarker);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           body: (currentLocation == null)
//               ? Center(child: Text("Loading"))
//               : GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                       target: LatLng(currentLocation!.latitude!,
//                           currentLocation!.longitude!),
//                       zoom: 15),
//                   //myLocationEnabled: true,
//                   tiltGesturesEnabled: true,
//                   compassEnabled: true,
//                   scrollGesturesEnabled: true,
//                   zoomGesturesEnabled: true,
//                   onMapCreated: _onMapCreated,
//                   markers: Set<Marker>.of(markers.values),
//                   polylines: Set<Polyline>.of(polylines.values),
//                 )),
//     );
//   }

//   void _onMapCreated(GoogleMapController controller) async {
//     mapController = controller;
//   }

//   _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
//     MarkerId markerId = MarkerId(id);
//     Marker marker =
//         Marker(markerId: markerId, icon: descriptor, position: position);
//     markers[markerId] = marker;
//   }

//   _addPolyLine() {
//     PolylineId id = PolylineId("poly");
//     Polyline polyline = Polyline(
//         polylineId: id, color: Colors.red, points: polylineCoordinates);
//     polylines[id] = polyline;
//     setState(() {});
//   }

//   _getPolyline() async {
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleAPiKey,
//       PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
//       PointLatLng(widget.lat, widget.long),
//       travelMode: TravelMode.driving,
//     );
//     //wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     }
//     _addPolyLine();
//   }
// }