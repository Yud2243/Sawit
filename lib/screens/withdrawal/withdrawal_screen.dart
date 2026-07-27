import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../profile/account_details_screen.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processWithdrawal(UserProvider userProvider) async {
    // Cegah double-click / spam tombol
    if (_isProcessing) return;

    String inputText = _amountController.text.trim();
    
    if (inputText.isEmpty) {
      _showSnackBar('Masukkan nominal yang ingin ditarik!', Colors.red);
      return;
    }

    double? requestedAmount = double.tryParse(inputText);

    if (requestedAmount == null || requestedAmount <= 0) {
      _showSnackBar('Format angka tidak valid!', Colors.red);
      return;
    }

    if (requestedAmount < 10000) {
      _showSnackBar('Minimal penarikan adalah Rp 10.000', Colors.orange.shade800);
      return;
    }

    if (requestedAmount > userProvider.currentBalance) {
      _showSnackBar('Saldo kamu tidak cukup!', Colors.red);
      return;
    }

    // Set loading
    setState(() => _isProcessing = true);

    // Tunggu proses Firestore selesai (dengan timeout agar tidak freeze)
    await userProvider.withdrawBalance(requestedAmount);

    if (context.mounted) {
      _showSnackBar('Berhasil menarik Rp ${requestedAmount.toInt()}!', Colors.green);
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!context.mounted) return;
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
            Text('Tarik Saldo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Cairkan hadiah ramah lingkungan Anda', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceInfo(userProvider),
            const SizedBox(height: 20),
            _buildAccountInfo(userProvider),
            const SizedBox(height: 24),
            _buildAmountInput(),
            const SizedBox(height: 40),
            _buildSubmitButton(userProvider),
          ],
        ),
      ),
    );
  }

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
          const Text('Saldo Tersedia', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            'Rp ${userProvider.currentBalance.toInt()}',
            style: const TextStyle(color: AppColors.primaryGold, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(UserProvider userProvider) {
    String accountDisplay;
    bool hasAccount = userProvider.bankName.isNotEmpty && userProvider.accountNumber.isNotEmpty;

    if (hasAccount) {
      String maskedNumber = userProvider.accountNumber.replaceAll(RegExp(r'.(?=.{4})'), '*');
      accountDisplay = '${userProvider.bankName} - $maskedNumber';
    } else {
      accountDisplay = 'Belum ada rekening. Tap "Ubah" untuk menambahkan.';
    }

    return Container(
      width: double.infinity,
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
                'Tujuan Penarikan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AccountDetailsScreen()),
                  );
                },
                child: const Text('Ubah', style: TextStyle(color: AppColors.primaryGold)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAccount ? (userProvider.accountName.isNotEmpty ? userProvider.accountName : userProvider.bankName) : 'Belum diatur',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accountDisplay,
                        style: TextStyle(
                          color: hasAccount ? AppColors.textGrey : Colors.orange,
                          fontSize: 14,
                        ),
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

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jumlah Penarikan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
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
        const Text('Minimal penarikan adalah Rp 10.000', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSubmitButton(UserProvider userProvider) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _processWithdrawal(userProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Tarik Sekarang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}
