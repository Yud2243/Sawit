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

  // Buat nyimpen ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'amount': amount,
      'type': type,
      'status': status,
    };
  }

  // Buat baca balik dari Firestore
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? '',
      status: map['status'] ?? '',
    );
  }
}