import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🌟 TAMBAHAN: Tarik data user aktif
import 'package:qr_flutter/qr_flutter.dart'; // 🌟 TAMBAHAN: Library pembuat QR asli
import '../../core/theme/app_colors.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🌟 LOGIKA BARU: Ambil data user dari Firebase
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? 'GUEST-123';
    final String userName = user?.displayName ?? 'Eco Warrior';
    
    // Bikin ID pendek (8 karakter) dari UID Firebase biar rapi di layar
    final String shortId = uid.length > 8 ? uid.substring(0, 8).toUpperCase() : uid;

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
          'Your QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Show this to the driver',
              style: TextStyle(fontSize: 16, color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              // 🌟 TAMBAHAN: Generate QR Code secara real-time berdasarkan UID
              child: QrImageView(
                data: uid, // Ini yang bakal masuk ke mesin scan
                version: QrVersions.auto,
                size: 200.0,
                foregroundColor: AppColors.textDark,
                errorCorrectionLevel: QrErrorCorrectLevel.M, // Toleransi kalau layar agak kotor
              ),
            ),
            const SizedBox(height: 32),
            Text(
              userName, // Nama asli dari database
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID: SAW-$shortId', // ID otomatis ngikutin kombinasi akun
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}