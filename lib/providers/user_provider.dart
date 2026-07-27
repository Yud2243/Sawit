import 'package:flutter/material.dart';
import '../models/transaction_model.dart'; 

class UserProvider with ChangeNotifier {
  double _currentBalance = 142000;
  int _totalLiters = 142;
  int _totalPickups = 28;
  int _litersThisMonth = 42;
  int _targetLiters = 100;

  // 🌟 TAMBAHAN BARU: Variabel Alamat (Pakai underscore biar seragam)
  String _street = '123 Green Street';
  String _city = 'Eco City';
  String _postalCode = '80361';

  // 🌟 TAMBAHAN BARU (ACCOUNT DETAILS): Variabel Rekening / E-Wallet 🌟
  // (Letaknya di bawah variabel alamat)
  String _bankName = 'GoPay';
  String _accountNumber = '081234567890';
  String _accountName = 'Eco Warrior';

  final List<TransactionModel> _transactions = [];

  double get currentBalance => _currentBalance;
  int get totalLiters => _totalLiters;
  int get totalPickups => _totalPickups;
  int get litersThisMonth => _litersThisMonth;
  int get targetLiters => _targetLiters;
  
  // 🌟 TAMBAHAN BARU: Getter Alamat
  String get street => _street;
  String get city => _city;
  String get postalCode => _postalCode;
  
  // 🌟 TAMBAHAN BARU (ACCOUNT DETAILS): Getter Rekening 🌟
  // (Letaknya di bawah getter alamat)
  String get bankName => _bankName;
  String get accountNumber => _accountNumber;
  String get accountName => _accountName;
  
  List<TransactionModel> get transactions => _transactions;

  // 🌟 TAMBAHAN BARU: Fungsi untuk update alamat
  void updateAddress(String newStreet, String newCity, String newPostal) {
    _street = newStreet;
    _city = newCity;
    _postalCode = newPostal;
    notifyListeners(); // Refresh layar
  }

  // 🌟 TAMBAHAN BARU (ACCOUNT DETAILS): Fungsi untuk update Rekening 🌟
  // (Letaknya di bawah fungsi update alamat)
  void updateAccount(String bank, String number, String name) {
    _bankName = bank;
    _accountNumber = number;
    _accountName = name;
    notifyListeners(); // Refresh layar
  }

  void withdrawBalance(double amount) {
    if (_currentBalance >= amount) {
      _currentBalance -= amount;
      
      _transactions.insert(0, TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        title: 'Withdraw Balance',
        type: 'withdrawal',
        amount: amount,
        date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        status: 'Proses',
      ));

      notifyListeners();
    }
  }

  void addRecycledOil(int liters, double earnings) {
    _totalLiters += liters;
    _litersThisMonth += liters;
    _currentBalance += earnings;
    _totalPickups += 1;

    _transactions.insert(0, TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      title: 'UCO Pickup ($liters Liters)',
      type: 'deposit',
      amount: earnings,
      date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      status: 'Selesai',
    ));

    notifyListeners();
  }
}