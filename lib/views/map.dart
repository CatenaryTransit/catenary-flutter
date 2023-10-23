import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:location/location.dart';
//import 'dart:ui_web';

class CatenaryMapView extends StatefulWidget {
  const CatenaryMapView({super.key});

  @override
  State<CatenaryMapView> createState() => _CatenaryMapViewState();
}

class _CatenaryMapViewState extends State<CatenaryMapView> {
  MaplibreMapController? mapController;
  Location location = Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _locationData;

  CameraPosition camPos = const CameraPosition(
      target: LatLng(0.0, 0.0), bearing: 0.0, tilt: 0.0, zoom: 0.0);

  Future<void> _onMapCreated(MaplibreMapController controller) async {
    setState(() {
      mapController = controller;
    });

    await controller.addSource(
        "geolocationcircle",
        const GeojsonSourceProperties(
          data: {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [0, 0]
            }
          },
        ));

    setState(() {
      camPos = mapController!.cameraPosition!;
    });

    controller.addListener(() {
      // however, this will listen to any changes to the object
      setState(() {
        camPos = mapController!.cameraPosition!;
      });
    });

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.enableBackgroundMode(enable: true);
    print("PERMISSION PASSED?");

    setState(() async {
      _locationData = await location.getLocation();
    });

    await controller.addSource(
        "busonly",
        const VectorSourceProperties(
            url: "https://martin.catenarymaps.org/busonly", minzoom: 6));

    await controller.addSource(
        "notbus",
        const VectorSourceProperties(
            url: "https://martin.catenarymaps.org/notbus", minzoom: 6));

    await controller.addLineLayer(
        "busonly",
        "busonlyshapes",
        LineLayerProperties(
          lineColor: [
            Expressions.concat,
            "#",
            [Expressions.get, "color"]
          ],
          lineWidth: 2,
          lineOpacity: 0.5,
        ),
        sourceLayer: "busonly",
        filter: [
          "!=",
          [Expressions.get, "onestop_feed_id"],
          "f-9-flixbus"
        ]);

    await controller.addSymbolLayer(
        "busonly",
        "labelbusshapes",
        const SymbolLayerProperties(
            symbolPlacement: "line",
            textField: [
              Expressions.coalesce,
              [Expressions.get, "route_label"]
            ],
            textColor: [
              Expressions.concat,
              "#",
              [Expressions.get, "text_color"]
            ],
            textHaloColor: [
              Expressions.concat,
              "#",
              [Expressions.get, "color"]
            ],
            textHaloWidth: 3,
            textHaloBlur: 0,
            textSize: [
              Expressions.interpolate,
              ['linear'],
              [Expressions.zoom],
              8,
              6,
              9,
              7,
              13,
              11
            ]),
        sourceLayer: "busonly",
        filter: [
          "!=",
          [Expressions.get, "onestop_feed_id"],
          "f-9-flixbus"
        ]);

    await controller.addLineLayer(
        "notbus",
        "railshapes",
        LineLayerProperties(
          lineColor: [
            Expressions.concat,
            "#",
            [Expressions.get, "color"]
          ],
          lineWidth: 3,
          lineOpacity: 0.7,
        ),
        sourceLayer: "notbus");

    await controller.addSymbolLayer(
        "notbus",
        "labelrailshapes",
        const SymbolLayerProperties(
            symbolPlacement: "line",
            textField: [
              Expressions.coalesce,
              [Expressions.get, "route_label"]
            ],
            textColor: [
              Expressions.concat,
              "#",
              [Expressions.get, "text_color"]
            ],
            textHaloColor: [
              Expressions.concat,
              "#",
              [Expressions.get, "color"]
            ],
            textHaloWidth: 3,
            textHaloBlur: 0,
            textSize: [
              Expressions.interpolate,
              ['linear'],
              [Expressions.zoom],
              8,
              6,
              9,
              7,
              13,
              11
            ]),
        sourceLayer: "notbus",
        filter: [
          "!=",
          [Expressions.get, "onestop_feed_id"],
          "f-9-flixbus"
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MaplibreMap(
          onMapCreated: _onMapCreated,
          compassEnabled: false,
          // compassViewPosition: CompassViewPosition.TopRight,
          styleString:
              'https://api.maptiler.com/maps/68c2a685-a6e4-4e26-b1c1-25b394003539/style.json?key=tf30gb2F4vIsBW5k9Msd',
          initialCameraPosition: const CameraPosition(
              target: LatLng(33, -117), zoom: 7.0, bearing: 0.0, tilt: 0.0),
          trackCameraPosition: true,
        ),
        floatingActionButton: Row(
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(35.0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Color(0xff0a233f),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    "${camPos.target.latitude.toStringAsFixed(5)}, "
                    "${camPos.target.longitude.toStringAsFixed(5)} "
                    "| Z: ${camPos.zoom.toStringAsFixed(2)} "
                    "| T: ${camPos.tilt.toStringAsFixed(2)}° "
                    "| B: ${camPos.bearing.toStringAsFixed(2)}°",
                    style: const TextStyle(
                      fontSize: 10.0,
                      fontFamily: "consolas",
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 25,
                ),
                FloatingActionButton(
                  onPressed: () {
                    print("MAP CTRL $mapController");
                    mapController!.animateCamera(CameraUpdate.bearingTo(0.0),
                        duration: const Duration(seconds: 2));
                  },
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF0a233f),
                  shape: const CircleBorder(),
                  mouseCursor: SystemMouseCursors.click,
                  tooltip: "Reset bearing to North",
                  child: const Icon(Icons.explore),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () {
                    if (_locationData != null) {
                      mapController!.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(_locationData?.latitude ?? 0.0,
                                _locationData?.longitude ?? 0.0),
                            zoom: 11.0,
                            bearing: 0.0,
                            tilt: 0.0,
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF0a233f),
                  shape: const CircleBorder(),
                  mouseCursor: SystemMouseCursors.click,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ],
        ));
  }
}
