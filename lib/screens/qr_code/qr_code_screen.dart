import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../dummy_data/app_data.dart'; // Ambil nama user dari dummy data

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({Key? key}) : super(key: key);

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
              // Pakai icon QR Code bawaan Flutter sebagai dummy
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 200,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppData.userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ID: SAW-12345678',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}