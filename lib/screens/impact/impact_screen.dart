import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Tambahan buat baca status login
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart'; // <-- Tambahan buat manggil layar login (sesuaikan path-nya)

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({Key? key}) : super(key: key);

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  @override
  Widget build(BuildContext context) {
    // Mesin ngecek: "Ada user yang lagi login nggak nih?"
    final User? user = FirebaseAuth.instance.currentUser;

    // 🔴 KALAU BELUM LOGIN: Tampilin halaman peringatan gembok
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGold,
          elevation: 0,
          title: const Text('Your Impact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 80, color: AppColors.primaryGold),
                const SizedBox(height: 16),
                const Text(
                  'Access Restricted',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please login to see your environmental impact and achievements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Lempar ke halaman Login, kalau udah beres, refresh layarnya otomatis
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      ).then((_) {
                        setState(() {}); // <-- Trik pinter biar layar otomatis kereload
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Login to Continue', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 🟢 KALAU UDAH LOGIN: Tampilin halaman Impact asli lu
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Your Impact',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              "See how you're helping the planet",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopImpactCard(),
            const SizedBox(height: 24),
            const Text(
              'Environmental Impact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            _buildImpactList(),
            const SizedBox(height: 24),
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            _buildAchievements(),
            const SizedBox(height: 32),
            _buildShareButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET UI ASLI LU DI BAWAH SINI ---

  Widget _buildTopImpactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, size: 48, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 16),
          const Text(
            '142',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
          ),
          const Text(
            'Total Liters Recycled',
            style: TextStyle(fontSize: 14, color: AppColors.textGrey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Amazing work! You're in the top 15% of eco warriors this month",
                    style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactList() {
    return Column(
      children: [
        _buildImpactItem(
          icon: Icons.water_drop_rounded,
          iconColor: Colors.blue,
          value: '142,000 liters',
          title: 'Water Saved',
          subtitle: 'Clean water protected from contamination',
        ),
        const SizedBox(height: 12),
        _buildImpactItem(
          icon: Icons.park_rounded,
          iconColor: Colors.green,
          value: '28 trees',
          title: 'Equivalent Trees Planted',
          subtitle: 'Environmental impact of your contribution',
        ),
        const SizedBox(height: 12),
        _buildImpactItem(
          icon: Icons.bolt_rounded,
          iconColor: Colors.amber,
          value: '85 kWh',
          title: 'Biodiesel Energy',
          subtitle: 'Renewable energy generated',
        ),
      ],
    );
  }

  Widget _buildImpactItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBadgeItem(icon: Icons.water_drop_outlined, title: 'First Drip', isEarned: true),
        _buildBadgeItem(icon: Icons.psychology_alt_outlined, title: 'Eco Starter', isEarned: true),
        _buildBadgeItem(icon: Icons.workspace_premium_outlined, title: '100 Liters', isEarned: true),
        _buildBadgeItem(icon: Icons.star_border_rounded, title: 'Top 10%', isEarned: false),
      ],
    );
  }

  Widget _buildBadgeItem({required IconData icon, required String title, required bool isEarned}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isEarned ? AppColors.lightGold.withOpacity(0.4) : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isEarned ? AppColors.primaryGold : Colors.grey.shade400,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isEarned ? AppColors.textDark : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton() {
    return Column(
      children: [
        const Text(
          'Proud of your impact? Share it!',
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share_rounded, color: AppColors.primaryGold),
            label: const Text(
              'Share on Social Media',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryGold, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}