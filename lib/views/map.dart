import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:location/location.dart';

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

  Future<void> _onMapCreated(MaplibreMapController controller) async {
    print("ON MAP CREATED");

    setState(() {
      mapController = controller;
      mapController!.addCircle(CircleOptions(
        circleRadius: 10,
        circleColor: '#2563EB',
        circleOpacity: 1,
        circleStrokeWidth: 1,
        circleStrokeColor: '#ffffff',
        geometry: LatLng(
            _locationData?.latitude ?? 0.0, _locationData?.longitude ?? 0.0),
      ));
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
;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Listener(
          // onPointerDown: (PointerDownEvent event) {
          //   print("CLICK!!");
          //   if(event.buttons == kSecondaryButton) {
          //     print("RIGHT CLICK??");
          //   }
          // },
          child: RawGestureDetector(
            // gestures: <Type, GestureRecognizerFactory>{
            //   // ImmediateMultiDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<ImmediateMultiDragGestureRecognizer>(
            //   //       () => ImmediateMultiDragGestureRecognizer(),
            //   //       (ImmediateMultiDragGestureRecognizer inst) {
            //   //         inst.onStart = (Offset pos) {
            //   //           print("Immediate Multi Drag $pos");
            //   //         };
            //   //       },
            //   // ),
            //   TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            //       () => TapGestureRecognizer(),
            //       (TapGestureRecognizer inst) {
            //         inst.onTap = () {
            //           print("=== RIGHT CLICK?? 1");
            //         };
            //         inst.onTapDown = (TapDownDetails det) {
            //           print("=== RIGHT CLICK?? 2");
            //         };
            //         inst.onSecondaryTap = () {
            //           print("=== RIGHT CLICK?? 3");
            //         };
            //         inst.onSecondaryTapDown = (TapDownDetails det) {
            //           print("=== RIGHT CLICK?? 4");
            //         };
            //         inst.onTertiaryTapDown = (TapDownDetails det) {
            //           print("=== RIGHT CLICK?? 5");
            //         };
            //         inst.onTertiaryTapUp = (TapUpDetails det) {
            //           print("=== RIGHT CLICK?? 6");
            //         };
            //       },
            //   ),
            //   PanGestureRecognizer: GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
            //       () => PanGestureRecognizer(),
            //       (PanGestureRecognizer inst) {
            //         inst.onUpdate = (DragUpdateDetails details) {
            //           print("Pan ${details.delta}");
            //           moveCamera(details.delta.dx, details.delta.dy);
            //         };
            //       },
            //   ),
            // },
            child: MaplibreMap(
              // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              //   Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer(),),
              //   // Factory<PanG>(() => EagerGestureRecognizer(),),
              // },
              onMapCreated: _onMapCreated,
              compassEnabled: false,
              styleString:
                  'https://api.maptiler.com/maps/68c2a685-a6e4-4e26-b1c1-25b394003539/style.json?key=tf30gb2F4vIsBW5k9Msd',
              initialCameraPosition: const CameraPosition(
                  target: LatLng(33, -117), zoom: 7.0, bearing: 0.0, tilt: 0.0),
              trackCameraPosition: true,
              // tiltGesturesEnabled: true,
              // zoomGesturesEnabled: true,
              // scrollGesturesEnabled: true,
              // rotateGesturesEnabled: true,
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(
              height: 25,
            ),
            FloatingActionButton(
              onPressed: () {
                print("MAP CTRL $mapController");
                mapController!.animateCamera(CameraUpdate.bearingTo(0.0), duration: const Duration(seconds: 2));
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
                if(_locationData != null) {
                  mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                            _locationData?.latitude ?? 0.0,
                            _locationData?.longitude ?? 0.0
                        ),
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
        )
    );
  }
}
