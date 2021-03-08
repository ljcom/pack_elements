import 'dart:html';
//import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps/google_maps.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:oph_core/models/oph.dart';
import 'package:geocoder/geocoder.dart' as coder;
//import '../global.dart' as g;
//import '../utils/locationJs.dart' as js;
import 'dart:ui' as ui;
import 'package:oph_core/models/preset.dart';

class MapxPage extends StatefulWidget {
  MapxPage(
      this.f, //this.addressField,
      this.title,
      this.preset);
  //this.onChanged);
  final FrmField f;
  //final FrmField addressField;
  //final LatLng presetLoc;
  final String title;
  final Preset preset;
  //final Function onChanged;
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapxPage> {
  LocationData curLoc;
  LocationData newLoc;
  Marker centerMarker = Marker();
  //Set<Marker> _markers = {};
  double scrw = 0;
  List<coder.Address> addresses = [];
  @override
  void initState() {
    super.initState();
    getLoc(widget.preset.apiKey);
  }

  void getLoc(String apiKey) async {
    bool getDV = false;
    if (widget.f.controller.text != '' &&
        widget.f.value.split(',').length < 2) {
      List<coder.Address> x = await coder.Geocoder.google(apiKey)
          .findAddressesFromQuery(widget.f.controller.text);
      if (x.length > 0) {
        //curLoc = LocationData(x[0].coordinates.latitude, x[0].coordinates.longitude);
        newLoc = curLoc;
        getDV = true;
      }
    } else if (widget.f != null && widget.f.value.split(',').length == 2) {
      //6°09'02.0"S 106°52'47.0"E -6.150562, 106.879728
      curLoc = LocationData.fromMap({
        'Latitude': double.tryParse(widget.f.value.split(',')[0]) ?? -6.150562,
        'longitude': double.tryParse(widget.f.value.split(',')[1]) ?? 106.879728
      });
      newLoc = curLoc;
      getDV = true;
    }

    if (!getDV) {
      curLoc = await determinePosition();
      newLoc = curLoc; //LocationData.fromMap({'latitude': 0, 'longitude': 0});
    }

/*
    _markers.add(
      Marker(
        markerId: MarkerId(widget.title),
        position: curLoc,
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  */
    /*
    if (newLoc != null) {
      coder.Geocoder.google(g.apiKey)
          .findAddressesFromCoordinates(
              coder.Coordinates(newLoc.lat, newLoc.lng))
          .then((v) {
        addresses = v;
        if (mounted) setState(() {});
      });
    }
*/
    setState(() {});
  }

  Future<LocationData> determinePosition() async {
    //LatLng latlng;
    //if (kIsWeb) {
    //getCurrentPosition((pos) {
    //latlng = LatLng(pos.coords.latitude, pos.coords.longitude);
    //return;
    //});
    //} else {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        //return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        //return;
      }
    }
    LocationData _locationData = await location.getLocation();
    //latlng = LatLng(_locationData.latitude, _locationData.longitude);
    //}
    return _locationData;
  }

/*
  Widget showMap() {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      initialCameraPosition: CameraPosition(target: curLoc, zoom: 18),
      //onMapCreated: (GoogleMapController controller) {
      //_controller.complete(controller);
      //},
      markers: _markers,
      onTap: (position) {
        newLoc = position;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId(widget.title),
            icon: BitmapDescriptor.defaultMarker,
            position: curLoc,
          ),
        );
        Geocoder.google(g.apiKey)
            .findAddressesFromCoordinates(
                Coordinates(newLoc.latitude, newLoc.longitude))
            .then((v) {
          addresses = v;
          popupWidget();
          setState(() {});
        });

        //if (onChange != null) onChange();
      },
    );
  }
*/
  Widget bodyWidget() {
    //LocationData loc =
    //  LocationData.fromMap({'latitude': -6.150562, 'longitude': 106.879728});
    return showMap(curLoc);
  }

  void saveAndBack(String coord, String address) {
    //widget.onChanged([coord, address]);
    Navigator.pop(context, [coord, address]);
  }

  /*
  Future<void> popupWidget() async {
    //var addresses = await Geocoder.local.findAddressesFromQuery(query);
    List<Widget> w = [];
    addresses.forEach((a) {
      w.add(Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
              child: Text(a.addressLine.toString()),
              onTap: () {
                String coord = a.coordinates.latitude.toString() +
                    ',' +
                    a.coordinates.longitude.toString();
                Navigator.pop(context);
                saveAndBack(coord, a.addressLine.toString());
              })));
    });

    await showDialog<void>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Select your location'),
            children: w,
          );
        });
  }
*/
  Widget showMap(LocationData myLatlng) {
    String htmlId = "googlemap";

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      //final myLatlng = LatLng(1.3521, 103.8198);

      final mapOptions = MapOptions()
        ..zoom = 18
        ..center = LatLng(myLatlng.latitude, myLatlng.longitude);

      final elem = DivElement()
        ..id = htmlId
        ..style.width = "100%"
        ..style.height = "100%"
        ..style.border = 'none';

      final map = GMap(elem, mapOptions);
      map.onCenterChanged.listen((event) {
        //print(map.center.lat);
        //print(map.center.lng);
        //print(map.zoom);
        newLoc = LocationData.fromMap(
            {'latitude': map.center.lat, 'longitude': map.center.lng});

        centerMarker.position = map.center;
      });

      map.onDragstart.listen((event) {});

      map.onDragend.listen((event) {
        setState(() {});
      });

      centerMarker = Marker(MarkerOptions()
        ..position = map.center //LatLng(myLatlng.latitude, myLatlng.longitude)
        ..map = map
        ..title = 'Your Location');

      return elem;
    });

    return HtmlElementView(viewType: htmlId);
  }

  Widget bottomWidget() {
    return Container(
        width: scrw,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
            //elevation: 0,
            //color: g.color1,
            //textColor: Colors.white,
            child: Text('Set this location'),
            onPressed: () {
              String coord = newLoc.latitude.toString() +
                  ',' +
                  newLoc.longitude.toString();

              saveAndBack(coord, coord);
            }));
  }

  @override
  Widget build(BuildContext context) {
    scrw = MediaQuery.of(context).size.width;
    return MaterialApp(
        home: Scaffold(
      appBar: PreferredSize(
          preferredSize: ui.Size.fromHeight(36.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: widget.preset.color2,
            title:
                const Text('Choose Location', style: TextStyle(fontSize: 16)),
          )),
      body: (curLoc == null) ? Text('Loading...') : bodyWidget(),
      bottomSheet: bottomWidget(),
      //bottomSheet: bottomWidget(),
    ));
  }
}
