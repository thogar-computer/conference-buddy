import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final double zoom;
  final void Function(LatLng)? onTap;
  final void Function(LatLng)? onLongPress;
  final bool interactive;
  final Marker? marker;

  const MapView({
    super.key,
    this.latitude,
    this.longitude,
    this.zoom = 14.0,
    this.onTap,
    this.onLongPress,
    this.interactive = true,
    this.marker,
  });

  @override
  Widget build(BuildContext context) {
    final center = latitude != null && longitude != null
        ? LatLng(latitude!, longitude!)
        : const LatLng(40.7128, -74.0060);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        onTap: onTap != null ? (tapPos, point) => onTap!(point) : null,
        onLongPress: onLongPress != null ? (tapPos, point) => onLongPress!(point) : null,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.conferencebuddy.app',
        ),
        if (marker != null)
          MarkerLayer(markers: [marker!]),
      ],
    );
  }
}

class LocationPickerMap extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;
  final void Function(double lat, double lon) onLocationSelected;

  const LocationPickerMap({
    super.key,
    this.initialLat,
    this.initialLon,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      _selectedLocation = LatLng(widget.initialLat!, widget.initialLon!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _selectedLocation ?? 
        (widget.initialLat != null && widget.initialLon != null 
            ? LatLng(widget.initialLat!, widget.initialLon!)
            : const LatLng(40.7128, -74.0060));

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14.0,
        onTap: (tapPos, point) {
          setState(() {
            _selectedLocation = point;
          });
          widget.onLocationSelected(point.latitude, point.longitude);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.conferencebuddy.app',
        ),
        if (_selectedLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedLocation!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
      ],
    );
  }
}