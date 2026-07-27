import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller buat nampung inputan text
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;        // Buat hide/show password
  bool _obscureConfirmPassword = true; // Buat hide/show konfirmasi password

  Future<void> _register() async {
    // 1. Validasi awal: Pastiin semua kolom diisi
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      _showSnackBar('Semua kolom wajib diisi, bro!', Colors.red);
      return;
    }

    // 2. Validasi Password: Pastiin password & konfirmasinya kembar
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Password dan Konfirmasi Password gak cocok!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Daftarin akun ke Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Simpan nama lengkap ke profil Firebase
        await user.updateDisplayName(_nameController.text.trim());

        // 4. Kirim email verifikasi ke user
        await user.sendEmailVerification();

        // 5. Karena lu pengen user balik ke halaman login dulu, 
        // kita harus otomatis sign out-in dia dulu dari Firebase biar gak langsung masuk Home
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          // Kasih notifikasi sukses yang jelas
          _showSnackBar('Registrasi berhasil! Silakan cek email lu buat verifikasi.', Colors.green);
          
          // Tendang balik ke halaman Login
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registrasi gagal!';
      if (e.code == 'weak-password') {
        errorMessage = 'Password-nya kemudaan, minimal 6 karakter!';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email ini udah dipake sama akun lain!';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email yang lu masukin salah!';
      }
      _showSnackBar(errorMessage, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi pembantu buat nampilin snackbar notifikasi biar gak nulis berulang
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Buat Akun',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bergabunglah dan mulailah membuat dampak!',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
                const SizedBox(height: 32),

                // 1. Kolom Full Name
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),

                // 2. Kolom Username
                _buildTextField(
                  controller: _usernameController,
                  label: 'Nama Pengguna',
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 16),

                // 3. Kolom Email
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // 4. Kolom Password + Icon Mata
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.primaryGold,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Kolom Confirm Password + Icon Mata
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Kata Sandi',
                  icon: Icons.lock_clock_outlined,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.primaryGold,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Register Dinamis (Loading Spinner kalau lagi proses)
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Reusable biar gak capek bikin dekorasi TextField berulang kali
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primaryGold, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}