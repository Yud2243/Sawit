import '../models/transaction_model.dart';

class AppData {
  // --- DUMMY DATA USER ---
  static const String userName = 'Sarah Johnson';
  static const double currentBalance = 1550000;
  static const int litersThisMonth = 35;
  static const int targetLiters = 60; 

  // --- DUMMY DATA TRANSAKSI ---
  static List<TransactionModel> getTransactions() {
    return [
      TransactionModel(
        id: 'TRX-001',
        title: 'Setor Minyak 5 Liter',
        date: '28 Apr 2026',
        amount: 27500,
        type: 'deposit',
        status: 'Selesai',
      ),
      TransactionModel(
        id: 'TRX-002',
        title: 'Tarik Saldo',
        date: '25 Apr 2026',
        amount: 25000,
        type: 'withdrawal',
        status: 'Selesai',
      ),
      TransactionModel(
        id: 'TRX-003',
        title: 'Setor Minyak 3 Liter',
        date: '20 Apr 2026',
        amount: 16500,
        type: 'deposit',
        status: 'Selesai',
      ),
      TransactionModel(
        id: 'TRX-004',
        title: 'Tarik Saldo',
        date: '15 Apr 2026',
        amount: 50000,
        type: 'Proses',
        status: 'Proses',
      ),
    ];
  }
}