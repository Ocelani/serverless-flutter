import 'package:dougota/service_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'api.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  BitmapDescriptor meIcon;

  //PolylinePoints polylinePoints;
  Location location;
  LocationData currentLocation;

  // final LatLng _center = const LatLng(45.521563, -122.677433);

//  -19.9333, -43.9361

  String googleAPIKey = "API_KEY";

  final _api = Api();

  void _onMapCreated(GoogleMapController controller) {
    // mapController = controller;
    // controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    showPinsOnMap();
  }

  @override
  void initState() {
    super.initState();

    location = new Location();

    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
    });

    // setIcon();

    setInitialLocation();
  }

  void setInitialLocation() async {
    currentLocation = await location.getLocation();
  }

  void showPinsOnMap() {
    var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    _markers.add(Marker(
      markerId: MarkerId('mePin'),
      position: pinPosition,
      // icon: Icons.location_pin
      // icon: meIcon
    ));
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: LatLng(currentLocation.latitude, currentLocation.longitude));

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    setState(() {
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      consumeAPI(pinPosition);

      _markers.removeWhere((m) => m.markerId.value == 'mePin');
      _markers.add(Marker(
        markerId: MarkerId('mePin'), position: pinPosition,
        // icon: meIcon
      ));
    });
  }

  void setIcon() async {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'assets/chaplin;png')
        .then((onValue) {
      meIcon = onValue;
    });
  }

  Future<void> consumeAPI(LatLng position) async {
    final url = _api.url('');
    final headers = _api.buildJsonHeader();
    final body =
        jsonEncode({'lat': position.latitude, 'lng': position.longitude});

    log(body);

    Response response = await post(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300)
      log(response.body);
    else
      throw ServiceException(code: response.statusCode, message: response.body);
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: LatLng(0.0, 0.0));

    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Mapa'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: _markers,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: _onMapCreated)
        ],
      ),
      // child:
    ));
  }
}
