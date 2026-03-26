import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/map_view.dart';

class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({super.key});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('hotel_latitude');
    final lon = prefs.getDouble('hotel_longitude');
    if (lat != null && lon != null) {
      setState(() {
        _latitude = lat;
        _longitude = lon;
      });
    }
  }

  Future<void> _saveLocation(double lat, double lon) async {
    setState(() {
      _latitude = lat;
      _longitude = lon;
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hotel_latitude', lat);
    await prefs.setDouble('hotel_longitude', lon);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hotel location saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Your Hotel')),
      body: Column(
        children: [
          Expanded(
            child: LocationPickerMap(
              initialLat: _latitude,
              initialLon: _longitude,
              onLocationSelected: _saveLocation,
            ),
          ),
          if (_latitude != null && _longitude != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lat: ${_latitude!.toStringAsFixed(4)}, Lon: ${_longitude!.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: const Row(
                children: [
                  Icon(Icons.touch_app, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap on the map to set your hotel location',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
