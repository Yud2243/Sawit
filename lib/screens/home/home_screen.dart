import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // 🌟 TAMBAHAN 1: Import package Provider 🌟
import '../../providers/user_provider.dart'; // 🌟 TAMBAHAN 2: Import file UserProvider (sesuaikan path-nya) 🌟
import '../../core/theme/app_colors.dart';
import '../pickup/pickup_screen.dart';
import '../history/history_screen.dart';
import '../withdrawal/withdrawal_screen.dart';
import '../qr_code/qr_code_screen.dart';
import '../location/location_screen.dart';
import '../auth/login_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _checkAuthAndNavigate(BuildContext context, Widget targetScreen) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 TAMBAHAN 3: Panggil UserProvider di awal build method 🌟
    final userProvider = Provider.of<UserProvider>(context, listen: true);

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
              
              // 🌟 TAMBAHAN 4: Oper data userProvider ke fungsi card saldo 🌟
              _buildBalanceCard(userProvider),
              
              const SizedBox(height: 20),
              _buildActionMenus(context),
              const SizedBox(height: 20),
              _buildCollectionPoints(context),
              const SizedBox(height: 20),
              
              // 🌟 TAMBAHAN 5: Oper data userProvider ke fungsi progress level 🌟
              _buildNextLevelCard(userProvider),
              
              const SizedBox(height: 20),
              
              // 🌟 TAMBAHAN 6: Oper data userProvider ke fungsi summary bulanan 🌟
              _buildMonthlySummary(userProvider),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final User? user = FirebaseAuth.instance.currentUser;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.lightGold,
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

  // 🌟 TAMBAHAN 7: Terima parameter UserProvider di sini 🌟
  Widget _buildBalanceCard(UserProvider userProvider) {
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
                // 🌟 TAMBAHAN 8: Ganti data dummy AppData jadi data live dari Provider 🌟
                'Rp ${userProvider.currentBalance.toInt()}',
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

  // 🌟 TAMBAHAN 9: Terima parameter UserProvider di sini 🌟
  Widget _buildNextLevelCard(UserProvider userProvider) {
    // 🌟 TAMBAHAN 10: Hitung progress & sisa target secara dinamis dari Provider 🌟
    final int remaining = userProvider.targetLiters - userProvider.litersThisMonth;
    final double progress = userProvider.litersThisMonth / userProvider.targetLiters;

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
            // 🌟 TAMBAHAN 11: Tampilkan total liter bulan ini dari Provider 🌟
            "You've collected ${userProvider.litersThisMonth} liters this month",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 🌟 TAMBAHAN 12: Terima parameter UserProvider di sini 🌟
  Widget _buildMonthlySummary(UserProvider userProvider) {
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
          // 🌟 TAMBAHAN 13: Ganti teks total liter bulanan dari data Provider 🌟
          _buildSummaryRow('Total Collected', '${userProvider.litersThisMonth} liters'),
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