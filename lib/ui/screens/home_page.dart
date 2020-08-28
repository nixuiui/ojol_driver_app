import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ojol_driver_app/helper/general_helper.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(-5.332469,105.285986);
const LatLng DEST_LOCATION = LatLng(-5.3586693,105.3315671);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int duration = 10;
  Timer timer;

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyCbEHsXGfuijWMzS2YxPk8Tls8BdqWVwaA";

  // for my custom marker pins
  BitmapDescriptor driverIcon;
  BitmapDescriptor startLocationIcon;
  BitmapDescriptor destinationIcon;
  
  Location location = Location();
  LocationData currentLocation;
  LocationData originLocation;
  LocationData destinationLocation;

  @override
  void initState() {
    super.initState();
    setMarkerIcon();
    timer = Timer.periodic(Duration(seconds: duration), (Timer t) => updateDriverMarker());
    location.changeSettings(accuracy: LocationAccuracy.high);
    setInitialLocation();
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
    });
  }

  void setInitialLocation() async {
    currentLocation = await location.getLocation();
    destinationLocation = LocationData.fromMap({
      "latitude": DEST_LOCATION.latitude,
      "longitude": DEST_LOCATION.longitude
    });
  }

  void setMarkerIcon() async {
    driverIcon = await getBitmapDescriptorFromAssetBytes("assets/marker_driver.png", 100);
  
    startLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5), 'assets/marker_start.png'
    );
    
    destinationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5), 'assets/marker_destination.png'
    );
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: currentLocation != null ? LatLng(currentLocation.latitude, currentLocation.longitude) : SOURCE_LOCATION
    );

    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        zoomControlsEnabled: false,
        initialCameraPosition: initialCameraPosition,
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          setDriverMarker();
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setRouteOrder(),
        label: Text("Set Order"),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  setRouteOrder() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
      PointLatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude)
    );

    _polylines.removeWhere((p) => p.polylineId.value == "orderRoute");
    Set<Polyline> _polylinesTemp = Set<Polyline>();
    if(result.points.isNotEmpty){
      result.points.forEach((PointLatLng point){
        polylineCoordinates.add(LatLng(point.latitude,point.longitude));
      });
      _polylinesTemp.add(Polyline(
        width: 5,
        polylineId: PolylineId("orderRoute"),
        color: Color.fromARGB(255, 40, 122, 198), 
        points: polylineCoordinates
      ));
    }
    _markers.removeWhere((m) => m.markerId.value == "startMarker");
    _markers.removeWhere((m) => m.markerId.value == "destinationMarker");
    _markers.add(Marker(
      markerId: MarkerId("startMarker"),
      position: SOURCE_LOCATION,
      icon: startLocationIcon
    ));
    _markers.add(Marker(
      markerId: MarkerId("destinationMarker"),
      position: DEST_LOCATION,
      icon: destinationIcon
    ));
    setState(() {
      _polylines = _polylinesTemp;
    });
  }

  void setDriverMarker() async {
    var pinPosition = currentLocation != null ? LatLng(currentLocation.latitude, currentLocation.longitude) : SOURCE_LOCATION;
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    _markers.removeWhere((m) => m.markerId.value == "driverMarker");
    _markers.add(Marker(
      markerId: MarkerId("driverMarker"),
      position: pinPosition,
      icon: driverIcon
    ));
  }

  void updateDriverMarker() async {   
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    setState(() {
      var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);
      _markers.removeWhere((m) => m.markerId.value == "driverMarker");
      _markers.add(Marker(
        markerId: MarkerId("driverMarker"),
        anchor: Offset(0,0),
        position: pinPosition,
        rotation: currentLocation.heading,
        icon: driverIcon
      ));
    });
    print("RELOAD");
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: duration), (Timer t) => updateDriverMarker());
  }

}