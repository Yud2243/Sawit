import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  // Controller untuk membaca ketikan alamat
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _postalController;

  @override
  void initState() {
    super.initState();
    // Isi dengan dummy text dulu
    _streetController = TextEditingController(text: '123 Green Street');
    _cityController = TextEditingController(text: 'Eco City');
    _postalController = TextEditingController(text: '80361');
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold,
        elevation: 0,
        title: const Text(
          'Address Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set your pickup location',
              style: TextStyle(fontSize: 16, color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            
            // 1. Kolom Nama Jalan
            _buildTextField(
              label: 'Street Address', 
              controller: _streetController, 
              icon: Icons.location_on_outlined,
              maxLines: 2, // Biar kotaknya agak lebar ke bawah untuk nulis alamat panjang
            ),
            const SizedBox(height: 20),
            
            // 2. Kolom Kota
            _buildTextField(
              label: 'City / District', 
              controller: _cityController, 
              icon: Icons.location_city_outlined,
            ),
            const SizedBox(height: 20),
            
            // 3. Kolom Kode Pos
            _buildTextField(
              label: 'Postal Code', 
              controller: _postalController, 
              icon: Icons.markunread_mailbox_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            
            // 4. Tombol Save
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
               // 🌟 KODE BARU: Kirim data ketikan ke UserProvider
               Provider.of<UserProvider>(context, listen: false).updateAddress(
                 _streetController.text,
                 _cityController.text,
                 _postalController.text,
               );

               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(
                   content: Text('Address saved successfully! 🏡'),
                   backgroundColor: Colors.green,
                 ),
               );
               Navigator.pop(context); // Kembali ke profil
             },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Save Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget custom untuk bikin form
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textDark),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryGold),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}