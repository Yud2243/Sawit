import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🌟 TAMBAHAN 1: Import Provider 🌟
import '../../providers/user_provider.dart'; // 🌟 TAMBAHAN 2: Import UserProvider 🌟
import '../../core/theme/app_colors.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // 🌟 TAMBAHAN 3: Fungsi utama buat proses penarikan saldo 🌟
  void _processWithdrawal(UserProvider userProvider) {
    // 1. Ambil teks yang diketik, hilangkan spasi/titik koma, lalu ubah jadi angka
    String inputText = _amountController.text.trim();
    
    if (inputText.isEmpty) {
      _showSnackBar('Masukkan nominal yang ingin ditarik!', Colors.red);
      return;
    }

    double? requestedAmount = double.tryParse(inputText);

    // 2. Cek apakah yang dimasukin beneran angka valid
    if (requestedAmount == null || requestedAmount <= 0) {
      _showSnackBar('Format angka tidak valid!', Colors.red);
      return;
    }

    // 3. Cek batas minimum penarikan (Rp 10.000)
    if (requestedAmount < 10000) {
      _showSnackBar('Minimal penarikan adalah Rp 10.000', Colors.orange.shade800);
      return;
    }

    // 4. Cek apakah saldo cukup
    if (requestedAmount > userProvider.currentBalance) {
      _showSnackBar('Saldo kamu tidak cukup!', Colors.red);
      return;
    }

    // 5. Kalau semua lolos, eksekusi pemotongan saldo lewat Provider
    userProvider.withdrawBalance(requestedAmount);

    // 6. Kasih notifikasi sukses dan balik ke Beranda
    _showSnackBar('Berhasil menarik Rp ${requestedAmount.toInt()}!', Colors.green);
    Navigator.pop(context);
  }

  // Fungsi utilitas buat nampilin notifikasi biar kodingan rapi
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
    // 🌟 TAMBAHAN 4: Panggil UserProvider biar kita bisa ngecek dan motong saldonya 🌟
    final userProvider = Provider.of<UserProvider>(context);

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
            Text('Withdraw Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Cash out your eco-rewards', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceInfo(userProvider), // 🌟 TAMBAHAN 5: Oper data userProvider 🌟
            const SizedBox(height: 24),
            _buildAmountInput(),
            const SizedBox(height: 40),
            _buildSubmitButton(userProvider), // 🌟 TAMBAHAN 6: Oper data userProvider 🌟
          ],
        ),
      ),
    );
  }

  // 🌟 TAMBAHAN 7: Terima data userProvider 🌟
  Widget _buildBalanceInfo(UserProvider userProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Available Balance', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            // 🌟 TAMBAHAN 8: Tampilkan saldo dinamis 🌟
            'Rp ${userProvider.currentBalance.toInt()}',
            style: const TextStyle(color: AppColors.primaryGold, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Withdrawal Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            hintText: '0',
            hintStyle: const TextStyle(color: AppColors.textGrey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGold, width: 2)),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Minimum withdrawal is Rp 10,000', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
      ],
    );
  }

  // 🌟 TAMBAHAN 9: Terima data userProvider 🌟
  Widget _buildSubmitButton(UserProvider userProvider) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        // 🌟 TAMBAHAN 10: Sambungin tombol ke fungsi logika penarikan 🌟
        onPressed: () => _processWithdrawal(userProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text('Withdraw Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}