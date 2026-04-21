import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/theme.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;
  const MapPickerScreen({super.key, required this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _pickedLocation;
  String _addressText = "Fetching address...";
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;

  // Safety Lock to prevent generic reverse-geocoding from overwriting specific names
  bool _isLockedBySuggestion = false;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialPosition;
    _getAddress(_pickedLocation);
  }

  Future<void> _fetchSuggestions(String input) async {
    if (input.length < 3) {
      setState(() => _showSuggestions = false);
      return;
    }
    final url = 'https://nominatim.openstreetmap.org/search?q=$input, Dehradun&format=json&limit=5';
    try {
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'com.duskdelivers.upes_app_v1'});
      if (response.statusCode == 200) {
        setState(() {
          _suggestions = json.decode(response.body);
          _showSuggestions = _suggestions.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint("Suggestion Error: $e");
    }
  }

  Future<void> _searchHostel(String query) async {
    if (query.isEmpty) return;
    try {
      List<Location> locations = await locationFromAddress("$query, Dehradun");
      if (locations.isNotEmpty) {
        final newPos = LatLng(locations[0].latitude, locations[0].longitude);

        setState(() {
          _isLockedBySuggestion = true;
          _pickedLocation = newPos;
          _addressText = query; // Locks to the name you searched for
          _showSuggestions = false;
        });

        _mapController.move(newPos, 17.0);
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location not found")));
    }
  }

  void _selectSuggestion(dynamic suggestion) {
    setState(() => _isLockedBySuggestion = true);

    final lat = double.parse(suggestion['lat']);
    final lon = double.parse(suggestion['lon']);
    final newPos = LatLng(lat, lon);

    _mapController.move(newPos, 17.0);

    setState(() {
      _pickedLocation = newPos;
      _addressText = suggestion['display_name'].split(',')[0];
      _showSuggestions = false;
      _searchController.text = suggestion['display_name'].split(',')[0];
    });

    FocusScope.of(context).unfocus();
  }

  Future<void> _getAddress(LatLng loc) async {
    if (_isLockedBySuggestion) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _addressText = "${place.name}, ${place.subLocality ?? ''}, ${place.locality ?? ''}";
        });
      }
    } catch (e) {
      setState(() => _addressText = "Custom Pin Location");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLocation,
              initialZoom: 15.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _isLockedBySuggestion = false;
                    _pickedLocation = pos.center!;
                    _showSuggestions = false;
                  });
                  _getAddress(_pickedLocation);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.duskdelivers.upes_app_v1',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickedLocation,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.location_on_rounded, color: AppTheme.primaryGold, size: 45),
                  ),
                ],
              ),
            ],
          ),

          // TOP SEARCH BAR
          Positioned(
            top: 60, left: 20, right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101010),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20)],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _fetchSuggestions,
                          onSubmitted: _searchHostel,
                          style: GoogleFonts.urbanist(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Search Hostel / Building...",
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 15),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showSuggestions)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101010),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        return ListTile(
                          title: Text(item['display_name'],
                              style: GoogleFonts.urbanist(color: Colors.white, fontSize: 13),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () => _selectSuggestion(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // UPDATED BOTTOM SHEET
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.map_rounded, color: AppTheme.primaryGold, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_addressText, style: GoogleFonts.urbanist(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600), maxLines: 2)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // NEW: DEDICATED SEARCH ACTION BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryGold.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        backgroundColor: AppTheme.primaryGold.withOpacity(0.05),
                      ),
                      onPressed: () => _searchHostel(_searchController.text),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_rounded, color: AppTheme.primaryGold, size: 20),
                          const SizedBox(width: 10),
                          Text("Locate",
                              style: GoogleFonts.urbanist(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // PRIMARY SET LOCATION BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => Navigator.pop(context, {'position': _pickedLocation, 'address': _addressText}),
                      child: Text("Set Delivery Location",
                          style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}