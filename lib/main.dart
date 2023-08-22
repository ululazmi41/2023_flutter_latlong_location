import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Location'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _publicToken = "<YOUR PUBLIC API KEY>";

  Location location = Location();

  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData _locationData = LocationData.fromMap({
    "latitude": 0.0,
    "longitude": 0.0,
  });

  double currentLat = 0.0;
  double currentLong = 0.0;

  Future<void> update() async {
    // TODO: utilize
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // TODO: show message if not granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    log("${_locationData.runtimeType} $_locationData");
    log("LAT: ${_locationData.latitude}");
    log("LNG: ${_locationData.longitude}");

    setState(() {
      currentLat = _locationData.latitude ?? 0;
      currentLong = _locationData.longitude ?? 0;
    });
  }

  MapboxMap? mapboxMap;
  PointAnnotation? pointAnnotation;
  PointAnnotationManager? pointAnnotationManager;

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.annotations.createPointAnnotationManager().then((value) async {
      pointAnnotationManager = value;
      final ByteData bytes =
          await rootBundle.load('assets/symbols/custom-icon.png');
      final Uint8List list = bytes.buffer.asUint8List();

      pointAnnotationManager?.createMulti([
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              currentLong,
              currentLat,
            ),
          ).toJson(),
          textField: "",
          textOffset: [0.0, -2.0],
          textColor: Colors.blue.value,
          iconSize: 0.06,
          iconOffset: [0.0, -5.0],
          symbolSortKey: 10,
          image: list,
        ),
      ]).then((value) {
        //
      });
    });
  }

  MapWidget? mapWidget;

  void renderMap() {
    setState(() {
      mapWidget = MapWidget(
        resourceOptions: ResourceOptions(accessToken: _publicToken),
        onMapCreated: _onMapCreated,
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(
              currentLong,
              currentLat,
            ),
          ).toJson(),
          zoom: 10.0,
        ),
      );
    });
  }

  bool isVisible = false;
  void renderVisibility() {
    setState(() {
      isVisible = true;
    });
  }

  @override
  initState() {
    super.initState();
    update();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      update();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).width,
              child: isVisible
                  ? mapWidget
                  : Center(
                      child: currentLat != 0.0
                          ? const Text("Location collected.")
                          : const Text("Waiting..."),
                    ),
            ),
            Text('LAT: $currentLat'),
            Text('LONG: $currentLong'),
            ElevatedButton(
              onPressed: currentLat != 0.0
                  ? () {
                      renderVisibility();
                      renderMap();
                    }
                  : null,
              child: const Text("Locate Me"),
            ),
          ],
        ),
      ),
    );
  }
}
