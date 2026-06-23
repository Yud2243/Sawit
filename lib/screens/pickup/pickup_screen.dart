import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🌟 TAMBAHAN 1: Import Provider 🌟
import '../../providers/user_provider.dart'; // 🌟 TAMBAHAN 2: Import UserProvider 🌟
import '../../core/theme/app_colors.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({Key? key}) : super(key: key);

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _volumeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // 🌟 TAMBAHAN 3: Fungsi utama buat proses Request Pickup 🌟
  void _processPickup(UserProvider userProvider) {
    String inputText = _volumeController.text.trim();

    if (inputText.isEmpty) {
      _showSnackBar('Masukkan volume minyak yang mau dijemput!', Colors.red);
      return;
    }

    int? volume = int.tryParse(inputText);

    // Validasi angka
    if (volume == null || volume <= 0) {
      _showSnackBar('Format angka tidak valid!', Colors.red);
      return;
    }

    // Validasi minimal 3 liter
    if (volume < 3) {
      _showSnackBar('Minimal penjemputan adalah 3 liter!', Colors.orange.shade800);
      return;
    }

    // Validasi maksimal 40 liter
    if (volume > 40) {
      _showSnackBar('Maksimal penjemputan adalah 40 liter per order!', Colors.red);
      return;
    }

    // Hitung pendapatan (Rp 5.500 per liter)
    double earnings = volume * 5500.0;

    // Masukin data ke Provider biar UI lain ikut update
    userProvider.addRecycledOil(volume, earnings);

    _showSnackBar('Order berhasil! Saldo kamu bertambah Rp ${earnings.toInt()}', Colors.green);
    Navigator.pop(context);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 TAMBAHAN 4: Panggil UserProvider 🌟
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Request Pickup',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Schedule your UCO collection',
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
            _buildAddressCard(),
            const SizedBox(height: 20),
            _buildVolumeInput(),
            const SizedBox(height: 24),
            _buildImportantRules(),
            const SizedBox(height: 24),
            _buildNotesInput(),
            const SizedBox(height: 40),
            _buildSubmitButton(userProvider), // 🌟 TAMBAHAN 5: Oper data provider ke tombol 🌟
          ],
        ),
      ),
    );
  }

  // 1. Card Alamat (Address)
  Widget _buildAddressCard() {
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
              const Text(
                'Pickup Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              TextButton(
                onPressed: () {}, 
                child: const Text('Edit', style: TextStyle(color: AppColors.primaryGold)),
              )
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primaryGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Home', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      SizedBox(height: 4),
                      Text(
                        '123 Green Street, Eco City, Jakarta 12345',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Input Volume Minyak
  Widget _buildVolumeInput() {
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
          const Text(
            'Volume (Liters)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _volumeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter volume',
              hintStyle: const TextStyle(color: AppColors.textGrey),
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixText: 'liters',
              suffixStyle: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Info Rules (Aturan Pickup)
  Widget _buildImportantRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Important Rules',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const Text(
          'Please follow these guidelines:',
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildRuleItem('Minimum 3 liters - We only collect batches of 3 liters or more'),
        _buildRuleItem('Maximum 40 liters - Per pickup request limit'),
        _buildRuleItem('Proper packaging - Use sealed containers, no leakage allowed'),
      ],
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.circle, size: 8, color: AppColors.primaryGold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.textDark, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // 4. Input Catatan Buat Driver
  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes for Driver',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Optional. Help the driver find you easier.',
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any special instructions? e.g., gate code, parking info',
            hintStyle: const TextStyle(color: AppColors.textGrey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  // 🌟 TAMBAHAN 6: Terima provider, lalu jalankan fungsi _processPickup 🌟
  Widget _buildSubmitButton(UserProvider userProvider) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _processPickup(userProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Next',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}