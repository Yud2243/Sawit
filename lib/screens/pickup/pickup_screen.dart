import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../profile/address_screen.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({Key? key}) : super(key: key);

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _volumeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processPickup(UserProvider userProvider) async {
    // Cegah double-click / spam tombol
    if (_isProcessing) return;

    String inputText = _volumeController.text.trim();

    if (inputText.isEmpty) {
      _showSnackBar('Masukkan volume minyak yang mau dijemput!', Colors.red);
      return;
    }

    int? volume = int.tryParse(inputText);

    if (volume == null || volume <= 0) {
      _showSnackBar('Format angka tidak valid!', Colors.red);
      return;
    }

    if (volume < 3) {
      _showSnackBar('Minimal penjemputan adalah 3 liter!', Colors.orange.shade800);
      return;
    }

    if (volume > 40) {
      _showSnackBar('Maksimal penjemputan adalah 40 liter per order!', Colors.red);
      return;
    }

    double earnings = volume * 5500.0;

    // Set loading
    setState(() => _isProcessing = true);

    // Tunggu proses Firestore selesai (dengan timeout agar tidak freeze)
    await userProvider.addRecycledOil(volume, earnings);

    if (context.mounted) {
      _showSnackBar('Order berhasil! Saldo kamu bertambah Rp ${earnings.toInt()}', Colors.green);
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
              'Jadwalkan Penjemputan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Jadwalkan pengumpulan minyak jelantah Anda',
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
            _buildSubmitButton(userProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        String fullAddress = '';
        if (userProvider.street.isNotEmpty) {
          fullAddress = '${userProvider.street}, ${userProvider.city}${userProvider.postalCode.isNotEmpty ? ', ${userProvider.postalCode}' : ''}';
        } else {
          fullAddress = 'Belum ada alamat. Tap "Ubah" untuk mengatur alamat.';
        }

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
                    'Alamat Penjemputan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddressScreen()),
                      );
                    }, 
                    child: const Text('Ubah', style: TextStyle(color: AppColors.primaryGold)),
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
                        children: [
                          const Text('Rumah', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          Text(
                            fullAddress,
                            style: TextStyle(
                              color: userProvider.street.isNotEmpty ? AppColors.textGrey : Colors.orange,
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
      },
    );
  }

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
            'Volume (Liter)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _volumeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan volume',
              hintStyle: const TextStyle(color: AppColors.textGrey),
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixText: 'liter',
              suffixStyle: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aturan Penting',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const Text(
          'Harap ikuti panduan berikut:',
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildRuleItem('Minimal 3 liter - Kami hanya menjemput 3 liter atau lebih'),
        _buildRuleItem('Maksimal 40 liter - Batas per permintaan penjemputan'),
        _buildRuleItem('Kemasan yang rapat - Gunakan wadah tertutup, tidak boleh bocor'),
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

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan untuk Pengemudi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Opsional. Bantu pengemudi menemukan Anda lebih mudah.',
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ada instruksi khusus? Misalnya kode gerbang, info parkir',
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

  Widget _buildSubmitButton(UserProvider userProvider) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _processPickup(userProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Selanjutnya',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}
