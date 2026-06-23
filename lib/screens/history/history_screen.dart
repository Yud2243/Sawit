import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/transaction_model.dart'; // Import model
import '../../dummy_data/app_data.dart'; // Import dummy data

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Ambil data dummy yang udah kita buat
  final List<TransactionModel> _allTransactions = AppData.getTransactions();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pisahin data berdasarkan tipe (deposit / withdrawal)
    final deposits = _allTransactions.where((t) => t.type == 'deposit').toList();
    final withdrawals = _allTransactions.where((t) => t.type == 'withdrawal').toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Transaction History',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'View your activity',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Bagian Header Hijau & Tabs
          Container(
            color: AppColors.primaryGold,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textGrey,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Deposit'),
                  Tab(text: 'Withdrawal'),
                ],
              ),
            ),
          ),
          
          // Bagian Konten Tab (Menampilkan List Data)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(deposits), // List untuk Deposit
                _buildTransactionList(withdrawals), // List untuk Withdrawal
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk bikin daftar (ListView) dari data transaksi
  Widget _buildTransactionList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No transaction yet', style: TextStyle(color: AppColors.textGrey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final trx = transactions[index];
        final isDeposit = trx.type == 'deposit';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isDeposit ? AppColors.lightGold.withOpacity(0.3) : Colors.red.shade50,
              child: Icon(
                isDeposit ? Icons.water_drop_rounded : Icons.account_balance_wallet_rounded,
                color: isDeposit ? AppColors.primaryGold : Colors.red,
              ),
            ),
            title: Text(
              trx.title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(trx.date, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 4),
                Text(
                  trx.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    // Kalau status Selesai warna hijau, kalau Proses warna orange
                    color: trx.status == 'Selesai' ? AppColors.primaryGold : Colors.orange,
                  ),
                ),
              ],
            ),
            trailing: Text(
              '${isDeposit ? '+' : '-'} Rp ${trx.amount.toInt()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDeposit ? AppColors.primaryGold : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}