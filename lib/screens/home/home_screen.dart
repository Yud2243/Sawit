import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Tambahan buat baca data user
import '../../core/theme/app_colors.dart';
import '../../dummy_data/app_data.dart';
import '../pickup/pickup_screen.dart';
import '../history/history_screen.dart';
import '../withdrawal/withdrawal_screen.dart';
import '../qr_code/qr_code_screen.dart';
import '../location/location_screen.dart';
import '../auth/login_screen.dart'; // <-- Tambahan buat lempar ke login kalau belum punya akses
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Fungsi Satpam: Ngecek user udah login atau belum sebelum pindah halaman
  void _checkAuthAndNavigate(BuildContext context, Widget targetScreen) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Belum login -> Tendang ke halaman Login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Udah login -> Lanjut ke halaman tujuan
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildBalanceCard(),
              const SizedBox(height: 20),
              _buildActionMenus(context),
              const SizedBox(height: 20),
              _buildCollectionPoints(context),
              const SizedBox(height: 20),
              _buildNextLevelCard(),
              const SizedBox(height: 20),
              _buildMonthlySummary(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Ambil data user yang lagi aktif dari Firebase
    final User? user = FirebaseAuth.instance.currentUser;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.lightGold,
              // Ambil foto dari Firebase kalau ada, kalau kosong pakai dummy
              backgroundImage: NetworkImage(
                user?.photoURL ?? 'https://i.pravatar.cc/150?img=5',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
                Text(
                  // Ambil nama dari Firebase, kalau null (belum login) tampilkan 'Guest'
                  user?.displayName ?? 'Guest',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark),
        )
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${AppData.currentBalance.toInt()}',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('Per liter', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('Rp 5,500', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenus(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MenuButton(
                icon: Icons.account_balance_wallet_outlined, 
                title: 'Withdraw', 
                onTap: () => _checkAuthAndNavigate(context, const WithdrawalScreen()),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MenuButton(
                icon: Icons.history_rounded, 
                title: 'History', 
                onTap: () => _checkAuthAndNavigate(context, const HistoryScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MenuButton(
                icon: Icons.local_shipping_outlined, 
                title: 'Pickup', 
                onTap: () => _checkAuthAndNavigate(context, const PickupScreen()),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MenuButton(
                icon: Icons.qr_code_scanner_rounded, 
                title: 'QR Code', 
                onTap: () => _checkAuthAndNavigate(context, const QrCodeScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionPoints(BuildContext context) {
    bool isWeb = const bool.fromEnvironment('dart.library.js_util');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nearby Collection Points', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LocationScreen()));
                },
                child: const Text('See All', 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryGold)
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: isWeb 
                ? Image.network(
                    'https://file.kemenkeu.go.id/api/v1/public/content/226d9c61-0988-466d-8692-0546c10b64d3.png',
                    fit: BoxFit.cover,
                  )
                : const _UserLocationMap(),
            ),
          ),

          const SizedBox(height: 16),
          _buildLocationInfo(),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.lightGold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.location_on, color: AppColors.primaryGold, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bank Sampah Jimbaran Utama',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.directions_walk, size: 12, color: AppColors.textGrey),
                  SizedBox(width: 4),
                  Text('1.2 km away', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextLevelCard() {
    final int remaining = AppData.targetLiters - AppData.litersThisMonth;
    final double progress = AppData.litersThisMonth / AppData.targetLiters;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGold,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Next Level', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.water_drop, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text('$remaining liters to go!', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress, 
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "You've collected ${AppData.litersThisMonth} liters this month",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          _buildSummaryRow('Total Collected', '${AppData.litersThisMonth} liters'),
          const Divider(height: 24),
          _buildSummaryRow('Last Month Bonus', 'Rp 25,000'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textGrey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuButton({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryGold,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _UserLocationMap extends StatefulWidget {
  const _UserLocationMap({Key? key}) : super(key: key);

  @override
  State<_UserLocationMap> createState() => _UserLocationMapState();
}

class _UserLocationMapState extends State<_UserLocationMap> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: _currentPosition == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            : GoogleMap(
                mapType: MapType.normal,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 15.0,
                ),
              ),
      ),
    );
  }
}