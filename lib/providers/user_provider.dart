import 'package:flutter/material.dart';
import '../models/transaction_model.dart'; 

class UserProvider with ChangeNotifier {
  double _currentBalance = 142000;
  int _totalLiters = 142;
  int _totalPickups = 28;
  int _litersThisMonth = 42;
  int _targetLiters = 100;

  final List<TransactionModel> _transactions = [];

  double get currentBalance => _currentBalance;
  int get totalLiters => _totalLiters;
  int get totalPickups => _totalPickups;
  int get litersThisMonth => _litersThisMonth;
  int get targetLiters => _targetLiters;
  
  List<TransactionModel> get transactions => _transactions;

  void withdrawBalance(double amount) {
    if (_currentBalance >= amount) {
      _currentBalance -= amount;
      
      _transactions.insert(0, TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 🌟 INI YANG BIKIN MERAH TADI 🌟
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
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 🌟 INI JUGA 🌟
      title: 'UCO Pickup ($liters Liters)',
      type: 'deposit',
      amount: earnings,
      date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      status: 'Selesai',
    ));

    notifyListeners();
  }
}