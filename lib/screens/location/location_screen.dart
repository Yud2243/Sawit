import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk daftar lokasi recycle
    final List<Map<String, dynamic>> locations = [
      {
        'name': 'Bank Sampah Jimbaran Utama',
        'address': 'Jl. Kampus Unud, Jimbaran, Kuta Selatan',
        'distance': '1.2 km',
        'isOpen': true,
      },
      {
        'name': 'Pusat Daur Ulang Kuta Selatan',
        'address': 'Jl. Bypass Ngurah Rai No.10, Kuta',
        'distance': '3.5 km',
        'isOpen': true,
      },
      {
        'name': 'SawOfIt Drop Point Kedonganan',
        'address': 'Area Parkir Pasar Ikan Kedonganan',
        'distance': '4.0 km',
        'isOpen': false,
      },
      {
        'name': 'TPS3R Samtaku Jimbaran',
        'address': 'Jl. Pasir Putih, Jimbaran',
        'distance': '5.2 km',
        'isOpen': true,
      }
    ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final loc = locations[index];
          return Container(
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
                // Icon Lokasi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on, color: AppColors.primaryGold, size: 28),
                ),
                const SizedBox(width: 16),
                // Detail Informasi
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
                          // Label Buka/Tutup
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
          );
        },
      ),
    );
  }
}