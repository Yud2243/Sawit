import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({Key? key}) : super(key: key);

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late TextEditingController _bankController;
  late TextEditingController _numberController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Ambil data rekening yang ada di Provider saat halaman dibuka
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _bankController = TextEditingController(text: userProvider.bankName);
    _numberController = TextEditingController(text: userProvider.accountNumber);
    _nameController = TextEditingController(text: userProvider.accountName);
  }

  @override
  void dispose() {
    _bankController.dispose();
    _numberController.dispose();
    _nameController.dispose();
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
          'Detail Akun',
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
              'Ke mana kami kirimkan pendapatan Anda?',
              style: TextStyle(fontSize: 16, color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            
            // 1. Bank / E-Wallet Name
            _buildTextField(
              label: 'Nama Bank / E-Wallet (misal: BCA, GoPay, OVO)', 
              controller: _bankController, 
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 20),
            
            // 2. Account Number
            _buildTextField(
              label: 'Nomor Rekening / Telepon', 
              controller: _numberController, 
              icon: Icons.numbers_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            
            // 3. Account Holder Name
            _buildTextField(
              label: 'Nama Pemilik Akun', 
              controller: _nameController, 
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 40),
            
            // 4. Tombol Save
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Simpan data ke UserProvider
                  Provider.of<UserProvider>(context, listen: false).updateAccount(
                    _bankController.text,
                    _numberController.text,
                    _nameController.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                    content: Text('Detail akun berhasil diperbarui! 💳'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Simpan Detail',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
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