class TransactionModel {
  final String id;
  final String title;
  final String date;
  final double amount;
  final String type; // 'deposit' (setor minyak) atau 'withdrawal' (tarik saldo)
  final String status; // 'Selesai' atau 'Proses'

  TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
  });
}