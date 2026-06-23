import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import 'register_screen.dart';
import '../main_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    // Validasi input absolut
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnackBar('Email dan Password wajib diisi secara valid.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Inisiasi proses otentikasi Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Bedah status verifikasi: Memastikan konsistensi data internal
      if (!userCredential.user!.emailVerified) {
        // Ambil instance user sebelum memutus sesi
        User? unverifiedUser = userCredential.user;
        
        // Putus sesi secara absolut untuk mencegah kebocoran akses
        await FirebaseAuth.instance.signOut();
        
        if (mounted) {
          // Tampilkan notifikasi dengan aksi sekunder (Resend Email)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Akses ditolak: Email belum diverifikasi.', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.orange.shade800,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5), // Durasi diperpanjang agar user bisa membaca
              action: SnackBarAction(
                label: 'KIRIM ULANG',
                textColor: Colors.white,
                onPressed: () async {
                  try {
                    await unverifiedUser?.sendEmailVerification();
                    if (mounted) {
                      _showSnackBar('Email verifikasi baru telah dikirimkan. Cek folder spam.', Colors.blue);
                    }
                  } catch (e) {
                    if (mounted) {
                      _showSnackBar('Gagal mengirim ulang. Tunggu beberapa saat sebelum mencoba lagi.', Colors.red);
                    }
                  }
                },
              ),
            ),
          );
        }
        return; // Terminasi proses secara paksa
      }

      // Jika lolos validasi, arahkan ke rute utama
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Analisis variabel error
      String errorMessage = 'Proses otentikasi gagal.';
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        errorMessage = 'Data email tidak ditemukan pada database.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Parameter kredensial yang diinput tidak valid.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Limitasi request tercapai. Sistem mengunci akses sementara.';
      }

      _showSnackBar(errorMessage, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi utilitas untuk merender notifikasi
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.eco_rounded, size: 80, color: AppColors.primaryGold),
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to continue your green journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryGold),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryGold),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.primaryGold,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: AppColors.textGrey)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      },
                      child: const Text(
                        'Register', 
                        style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}