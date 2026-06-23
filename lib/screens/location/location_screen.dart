import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 🌟 TAMBAHAN: Import library peta
import 'dart:async';
import '../../core/theme/app_colors.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // Controller buat ngendaliin kamera peta
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  // Titik tengah default (Kita setting ke area Jimbaran/Unud)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-8.7963, 115.1765), // Koordinat area Jimbaran
    zoom: 13.5,
  );

  // Data lokasi yang udah dimodif pake koordinat asli
  final List<Map<String, dynamic>> locations = [
    {
      'name': 'Bank Sampah Jimbaran Utama',
      'address': 'Jl. Kampus Unud, Jimbaran',
      'distance': '1.2 km',
      'isOpen': true,
      'latLng': const LatLng(-8.7981, 115.1722),
    },
    {
      'name': 'Pusat Daur Ulang Kuta Selatan',
      'address': 'Jl. Bypass Ngurah Rai No.10',
      'distance': '3.5 km',
      'isOpen': true,
      'latLng': const LatLng(-8.7845, 115.1856),
    },
    {
      'name': 'SawOfIt Drop Point Kedonganan',
      'address': 'Area Parkir Pasar Ikan Kedonganan',
      'distance': '4.0 km',
      'isOpen': false,
      'latLng': const LatLng(-8.7562, 115.1687),
    },
    {
      'name': 'TPS3R Samtaku Jimbaran',
      'address': 'Jl. Pasir Putih, Jimbaran',
      'distance': '5.2 km',
      'isOpen': true,
      'latLng': const LatLng(-8.7712, 115.1798),
    }
  ];

  // Fungsi buat ngerubah titik merah (marker) di peta berdasarkan data di atas
  Set<Marker> _createMarkers() {
    return locations.map((loc) {
      return Marker(
        markerId: MarkerId(loc['name']),
        position: loc['latLng'],
        infoWindow: InfoWindow(
          title: loc['name'],
          snippet: loc['isOpen'] ? 'Open Now' : 'Closed',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange), // Warna pin
      );
    }).toSet();
  }

  // Fungsi buat ngebawa kamera terbang ke titik yang diklik
  Future<void> _goToLocation(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 16.0), // Zoom in pas diklik
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Collection Points',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🌟 BAGIAN ATAS: GOOGLE MAPS 🌟
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // Peta ngambil 40% layar
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialPosition,
              markers: _createMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false, // Matiin tombol zoom +/- biar rapi
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),

          // 🌟 BAGIAN BAWAH: LIST LOKASI 🌟
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final loc = locations[index];
                
                // Pake InkWell biar list-nya bisa diklik
                return InkWell(
                  onTap: () => _goToLocation(loc['latLng']), // Terbang ke lokasi pas diklik
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_on, color: AppColors.primaryGold, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc['name'],
                                style: const TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold, 
                                  color: AppColors.textDark
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loc['address'],
                                style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.directions_walk, size: 14, color: AppColors.textGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    loc['distance'],
                                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: loc['isOpen'] ? Colors.green.shade50 : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      loc['isOpen'] ? 'Open' : 'Closed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: loc['isOpen'] ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}