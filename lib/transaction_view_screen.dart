import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'logic/transaction_model.dart';
import 'logic/transaction_provider.dart';
import 'logic/financial_provider.dart';
import 'logic/financial_models.dart';

class TransactionViewScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionViewScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1E60FE)),
            onPressed: () {
              // Share logic
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFFF5252)),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Icon Hero Section
            Center(
              child: Hero(
                tag: 'trans_icon_${transaction.id}',
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: transaction.category.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(transaction.category.icon, color: transaction.category.color, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              transaction.category.name,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '${isIncome ? '+' : '-'}${currencyFormatter.format(transaction.amount)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: isIncome ? Colors.green : const Color(0xFFFF5252),
              ),
            ),
            const SizedBox(height: 32),

            // Receipt Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(context, 'Nama Transaksi', transaction.title),
                  const Divider(height: 32),
                  _buildDetailRow(context, 'Tanggal', DateFormat('EEEE, dd MMMM yyyy').format(transaction.date)),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, 'Waktu', DateFormat('HH:mm').format(transaction.date)),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, 'Jenis', isIncome ? 'Pemasukan' : 'Pengeluaran'),
                  const SizedBox(height: 16),
                  Consumer<FinancialProvider>(
                    builder: (context, finProvider, child) {
                      final asset = finProvider.assets.firstWhere(
                        (a) => a.id == transaction.assetId,
                        orElse: () => FinancialAsset(id: '', name: 'Tunai (Lama)', amount: 0, type: AssetType.cash, icon: Icons.money, color: Colors.grey),
                      );
                      return _buildDetailRow(context, 'Sumber Dana', asset.name);
                    },
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                    const Divider(height: 32),
                    _buildDetailRow(context, 'Catatan', transaction.note!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Image Section
            if (transaction.imagePath != null && transaction.imagePath!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 12),
                    child: Text('Bukti Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      File(transaction.imagePath!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Transaksi?'),
        content: const Text('Data ini bakal hilang permanen loh gess.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(transaction.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from view screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
