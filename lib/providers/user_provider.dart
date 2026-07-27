import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==== Data user, default 0 / kosong (nilai user baru sebelum di-load) ====
  double _currentBalance = 0;
  int _totalLiters = 0;
  int _totalPickups = 0;
  int _litersThisMonth = 0;
  int _targetLiters = 100;

  String _street = '';
  String _city = '';
  String _postalCode = '';

  String _bankName = '';
  String _accountNumber = '';
  String _accountName = '';

  final List<TransactionModel> _transactions = [];

  bool isLoading = false;
  bool _isLoadingData = false; // Cegah double-load async

  // ==== Getters ====
  double get currentBalance => _currentBalance;
  int get totalLiters => _totalLiters;
  int get totalPickups => _totalPickups;
  int get litersThisMonth => _litersThisMonth;
  int get targetLiters => _targetLiters;

  String get street => _street;
  String get city => _city;
  String get postalCode => _postalCode;

  String get bankName => _bankName;
  String get accountNumber => _accountNumber;
  String get accountName => _accountName;

  List<TransactionModel> get transactions => _transactions;

  bool get isLoadingData => _isLoadingData;

  UserProvider() {
    // Dengarkan perubahan status login (login/logout) secara otomatis
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // Microtask delay supaya tidak tabrakan dengan build widget pertama
        Future.microtask(() => loadUserData(user.uid));
      } else {
        _resetData();
      }
    });
  }

  // ==== Load data user dari Firestore, buat baru kalau belum ada ====
  Future<void> loadUserData(String uid) async {
    // Cegah double-load yang bikin freeze
    if (_isLoadingData) return;
    _isLoadingData = true;
    isLoading = true;
    notifyListeners();

    try {
      final docRef = _firestore.collection('users').doc(uid);
      final docSnap = await docRef.get().timeout(const Duration(seconds: 10));

      if (!docSnap.exists) {
        // User baru pertama kali login -> saldo & data lain mulai dari 0
        final initialData = {
          'currentBalance': 0,
          'totalLiters': 0,
          'totalPickups': 0,
          'litersThisMonth': 0,
          'targetLiters': 100,
          'street': '',
          'city': '',
          'postalCode': '',
          'bankName': '',
          'accountNumber': '',
          'accountName': '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        await docRef.set(initialData).timeout(const Duration(seconds: 10));
        _applyData(initialData);
      } else {
        _applyData(docSnap.data()!);
      }

      await _loadTransactions(uid);
    } catch (e) {
      // Kalau Firestore gagal/lambat, jangan bikin app nge-hang
      debugPrint('UserProvider.loadUserData ERROR: $e');
    } finally {
      isLoading = false;
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> _loadTransactions(String uid) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .get()
        .timeout(const Duration(seconds: 10));

    _transactions.clear();
    _transactions.addAll(
      snap.docs.map((d) => TransactionModel.fromMap(d.data())),
    );
  }

  void _applyData(Map<String, dynamic> data) {
    _currentBalance = (data['currentBalance'] ?? 0).toDouble();
    _totalLiters = (data['totalLiters'] ?? 0) as int;
    _totalPickups = (data['totalPickups'] ?? 0) as int;
    _litersThisMonth = (data['litersThisMonth'] ?? 0) as int;
    _targetLiters = (data['targetLiters'] ?? 100) as int;
    _street = data['street'] ?? '';
    _city = data['city'] ?? '';
    _postalCode = data['postalCode'] ?? '';
    _bankName = data['bankName'] ?? '';
    _accountNumber = data['accountNumber'] ?? '';
    _accountName = data['accountName'] ?? '';
  }

  // ==== Reset saat logout, biar tidak nyangkut ke user berikutnya ====
  void _resetData() {
    _currentBalance = 0;
    _totalLiters = 0;
    _totalPickups = 0;
    _litersThisMonth = 0;
    _targetLiters = 100;
    _street = '';
    _city = '';
    _postalCode = '';
    _bankName = '';
    _accountNumber = '';
    _accountName = '';
    _transactions.clear();
    notifyListeners();
  }

  // ==== Update alamat ====
  Future<void> updateAddress(String newStreet, String newCity, String newPostal) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Update lokal dulu biar UI cepat merespons
    _street = newStreet;
    _city = newCity;
    _postalCode = newPostal;
    notifyListeners();

    // Simpan ke Firestore di background
    try {
      await _firestore.collection('users').doc(uid).update({
        'street': _street,
        'city': _city,
        'postalCode': _postalCode,
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('updateAddress ERROR: $e');
    }
  }

  // ==== Update rekening / e-wallet ====
  Future<void> updateAccount(String bank, String number, String name) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Update lokal dulu biar UI cepat merespons
    _bankName = bank;
    _accountNumber = number;
    _accountName = name;
    notifyListeners();

    // Simpan ke Firestore di background
    try {
      await _firestore.collection('users').doc(uid).update({
        'bankName': _bankName,
        'accountNumber': _accountNumber,
        'accountName': _accountName,
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('updateAccount ERROR: $e');
    }
  }

  // ==== Dipanggil dari PickupScreen setelah request pickup berhasil ====
  Future<void> addRecycledOil(int liters, double earnings) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Update lokal dulu
    _totalLiters += liters;
    _litersThisMonth += liters;
    _currentBalance += earnings;
    _totalPickups += 1;

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Penjemputan UCO ($liters Liter)',
      type: 'deposit',
      amount: earnings,
      date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      status: 'Selesai',
    );
    _transactions.insert(0, transaction);
    notifyListeners(); // Update UI dulu tanpa nunggu Firestore

    // Simpan ke Firestore di background
    final docRef = _firestore.collection('users').doc(uid);
    try {
      await docRef.update({
        'currentBalance': _currentBalance,
        'totalLiters': _totalLiters,
        'litersThisMonth': _litersThisMonth,
        'totalPickups': _totalPickups,
      }).timeout(const Duration(seconds: 10));
      await docRef.collection('transactions').doc(transaction.id).set({
        ...transaction.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('addRecycledOil ERROR: $e');
    }
  }

  // ==== Dipanggil dari WithdrawalScreen setelah validasi saldo cukup ====
  Future<void> withdrawBalance(double amount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _currentBalance < amount) return;

    // Update lokal dulu
    _currentBalance -= amount;

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Tarik Saldo',
      type: 'withdrawal',
      amount: amount,
      date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      status: 'Proses',
    );
    _transactions.insert(0, transaction);
    notifyListeners(); // Update UI dulu tanpa nunggu Firestore

    // Simpan ke Firestore di background
    final docRef = _firestore.collection('users').doc(uid);
    try {
      await docRef.update({'currentBalance': _currentBalance}).timeout(const Duration(seconds: 10));
      await docRef.collection('transactions').doc(transaction.id).set({
        ...transaction.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('withdrawBalance ERROR: $e');
    }
  }
}
