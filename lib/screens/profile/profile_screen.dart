import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Tambahan buat cek status Firebase
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart'; // <-- Pastiin path menuju file LoginScreen lu udah bener

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Mesin cek status akun di Firebase secara real-time
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            _buildStatsRow(user),
            const SizedBox(height: 32),
            _buildMenuSection(context, user),
            const SizedBox(height: 40), // Padding bawah
          ],
        ),
      ),
    );
  }

  // 1. Header Profil (Dinamis: Ikut status login)
  Widget _buildProfileHeader(User? user) {
    bool isLoggedIn = user != null;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGold, width: 2),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.lightGold,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=5', // Foto profil default
                ),
              ),
            ),
            if (isLoggedIn)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Kalau sudah login tampilkan nama asli dari Firebase, kalau belum jadi Guest Account
        Text(
          isLoggedIn ? (user.displayName ?? 'Eco Warrior') : 'Guest Account',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        
        // Email dinamis sesuai akun Firebase
        Text(
          isLoggedIn ? (user.email ?? '') : 'Please login to track your journey',
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lightGold.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isLoggedIn ? 'Eco Warrior Level 3' : 'Level 0 (Guest)',
            style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // 2. Baris Statistik (Otomatis jadi 0 kalau belum login)
  Widget _buildStatsRow(User? user) {
    bool isLoggedIn = user != null;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Text(
                  isLoggedIn ? '142' : '0',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Total Liters',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Text(
                  isLoggedIn ? '28' : '0',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pickups',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Daftar Menu Pengaturan (Menampilkan Login/Register kalau belum login)
  Widget _buildMenuSection(BuildContext context, User? user) {
    bool isLoggedIn = user != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Personal Information',
            subtitle: isLoggedIn ? (user.displayName ?? 'No Name') : 'Login to view information',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Address',
            subtitle: isLoggedIn ? '123 Green Street, Eco City' : 'Login to view address',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Account Details',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          
          // 👇 LOGIKA SWITCH TOMBOL LOGOUT VS LOGIN/REGISTER 👇
          isLoggedIn
              ? _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout Account',
                  isDestructive: true,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    setState(() {}); // Refresh halaman biar langsung balik ke mode Guest
                  },
                )
              : _buildMenuItem(
                  icon: Icons.login_rounded,
                  title: 'Login / Register',
                  isLoginButton: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    ).then((_) {
                      setState(() {}); // Refresh halaman pas balik dari screen login
                    });
                  },
                ),
        ],
      ),
    );
  }

  // Widget Bantuan untuk Item Menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDestructive = false,
    bool isLoginButton = false,
    required VoidCallback onTap,
  }) {
    Color primaryColor = AppColors.textDark;
    Color bgColor = AppColors.lightGold.withOpacity(0.2);

    if (isDestructive) {
      primaryColor = Colors.red;
      bgColor = Colors.red.shade50;
    } else if (isLoginButton) {
      primaryColor = AppColors.primaryGold;
      bgColor = AppColors.lightGold.withOpacity(0.4);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}