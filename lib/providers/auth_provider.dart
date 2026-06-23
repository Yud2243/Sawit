import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  // Getter buat ngambil data user yang lagi aktif
  User? get user => _user;

  // Cek apakah user sudah login atau masih guest
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    // Otomatis mantau status login user setiap kali aplikasi dibuka
    _auth.authStateChanges().listen((User? newUser) {
      _user = newUser;
      notifyListeners(); // Fungsi ini buat ngabarin semua halaman kalau ada perubahan data
    });
  }

  // Fungsi buat refresh data user (misal abis update nama)
  Future<void> refreshUser() async {
    _user = _auth.currentUser;
    await _user?.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }
}