import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart'; 

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _nicknameController; // 🌟 Ubah jadi nickname

  @override
  void initState() {
    super.initState();
    // Karena Firebase Auth cuma nyimpen displayName, kita asumsikan itu Nickname/Nama user
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _nicknameController = TextEditingController(text: user?.displayName ?? ''); // Sama-sama narik dari displayName
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nicknameController.dispose(); // 🌟 Jangan lupa di-dispose
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
          'Informasi Pribadi',
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
            'Perbarui data pribadi Anda',
              style: TextStyle(fontSize: 16, color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            
            // 1. Kolom Full Name
            _buildTextField(
              label: 'Nama Lengkap', 
              controller: _nameController, 
              icon: Icons.person_outline
            ),
            const SizedBox(height: 20),
            
            // 2. Kolom Email (Read-Only)
            _buildTextField(
              label: 'Alamat Email', 
              controller: _emailController, 
              icon: Icons.email_outlined, 
              isReadOnly: true
            ),
            const SizedBox(height: 20),
            
            // 3. Kolom Nickname 🌟 (Menggantikan Phone Number)
            _buildTextField(
              label: 'Nama Panggilan', 
              controller: _nicknameController, 
              icon: Icons.badge_outlined, // Ikon ID card/badge
            ),
            const SizedBox(height: 40),
            
           // 4. Tombol Save
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (user != null) {
                    try {
                      // 1. Update nama/nickname ke server Firebase
                      // (Karena Firebase Auth cuma punya 1 slot nama, kita simpan dari input Nickname)
                      await user!.updateDisplayName(_nicknameController.text);
                      
                      // 2. Refresh data user di aplikasi
                      await user!.reload();

                      // 3. Munculkan notifikasi sukses beneran
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil berhasil diperbarui! 🌱'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // 4. Otomatis kembali ke halaman Profile setelah save
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      // Kalau gagal/error (misal putus koneksi)
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal memperbarui profil: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Simpan Perubahan',
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
    bool isReadOnly = false,
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
          readOnly: isReadOnly,
          style: TextStyle(color: isReadOnly ? Colors.grey : AppColors.textDark),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isReadOnly ? Colors.grey : AppColors.primaryGold),
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