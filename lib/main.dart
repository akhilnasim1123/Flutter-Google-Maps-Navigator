import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/directions.dart' as gmaps_ws;

void main() {
  runApp(const MyApp());
}

const String googleApiKey = 'YOUR_API_KEY'; // Replace with your API key

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Map Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Flutter Map Demo'),
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
  gmaps.GoogleMapController? mapController;
  gmaps.LatLng? _currentLatLng;
  Set<gmaps.Polyline> _polylines = {};
  final _places = GoogleMapsPlaces(apiKey: googleApiKey);
  final _directions = gmaps_ws.GoogleMapsDirections(apiKey: googleApiKey);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Get user location
  Future<void> _determinePosition() async {
    try {
      Position position = await _getCurrentLocation();
      setState(() {
        _currentLatLng = gmaps.LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool opened = await Geolocator.openLocationSettings();
      if (!opened) {
        return Future.error('Location services are disabled.');
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(gmaps.GoogleMapController controller) {
    mapController = controller;
    if (_currentLatLng != null) {
      mapController!.animateCamera(
        gmaps.CameraUpdate.newLatLng(_currentLatLng!),
      );
    }
  }

  // Search location using Google Places
  Future<void> _searchLocation() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: googleApiKey,
      mode: Mode.overlay,
      language: 'en',
    );

    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      gmaps.LatLng destination = gmaps.LatLng(lat, lng);
      mapController!.animateCamera(gmaps.CameraUpdate.newLatLng(destination));

      if (_currentLatLng != null) {
        _getDirections(_currentLatLng!, destination);
      }
    }
  }

  // Get directions and draw polyline
  Future<void> _getDirections(gmaps.LatLng start, gmaps.LatLng end) async {
    final result = await _directions.directionsWithLocation(
      gmaps_ws.Location(lat: start.latitude, lng: start.longitude),
      gmaps_ws.Location(lat: end.latitude, lng: end.longitude),
      travelMode: gmaps_ws.TravelMode.driving,
    );

    if (result.isOkay) {
      final route = result.routes[0].overviewPolyline.points;
      List<gmaps.LatLng> points = _decodePoly(route);

      setState(() {
        _polylines.clear();
        _polylines.add(
          gmaps.Polyline(
            polylineId: gmaps.PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    }
  }

  // Decode polyline from Google Directions
  List<gmaps.LatLng> _decodePoly(String poly) {
    List<gmaps.LatLng> points = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(gmaps.LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _currentLatLng == null
            ? const Center(child: CircularProgressIndicator())
            : gmaps.GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: gmaps.CameraPosition(
                  target: _currentLatLng!,
                  zoom: 15,
                ),
                mapType: gmaps.MapType.hybrid,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                polylines: _polylines,
                buildingsEnabled: true,
                compassEnabled: true,
                indoorViewEnabled: true,
                mapToolbarEnabled: true,
                zoomControlsEnabled: true,
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'current_location',
            backgroundColor: Colors.black,
            onPressed: () async {
              Position position = await _getCurrentLocation();
              _currentLatLng = gmaps.LatLng(position.latitude, position.longitude);
              mapController!.animateCamera(
                gmaps.CameraUpdate.newLatLng(_currentLatLng!),
              );
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'search',
            backgroundColor: Colors.blue,
            onPressed: _searchLocation,
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
 