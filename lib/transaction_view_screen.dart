import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'logic/transaction_model.dart';
import 'logic/transaction_provider.dart';
import 'logic/financial_provider.dart';
import 'logic/financial_models.dart';
import 'notes_screen.dart';

class TransactionViewScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionViewScreen({super.key, required this.transaction});

  Future<void> _shareTransaction(BuildContext context, Transaction t) async {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final isIncome = t.type == TransactionType.income;
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(t.date);
    
    final shareText = '''
🚀 *Saldoku Transaction Report* 🚀
----------------------------------
📌 *Nama:* ${t.title}
💰 *Nominal:* ${isIncome ? '+' : '-'}${currencyFormatter.format(t.amount)}
📅 *Tanggal:* $dateStr
📂 *Kategori:* ${t.category.name}
📝 *Catatan:* ${t.note ?? '-'}

_Shared from Saldoku App_
''';

    try {
      if (t.imagePath != null && t.imagePath!.isNotEmpty) {
        final file = XFile(t.imagePath!);
        await Share.shareXFiles([file], text: shareText);
      } else {
        await Share.share(shareText);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal berbagi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // Find the latest version of this transaction
        final currentTransaction = provider.transactions.firstWhere(
          (t) => t.id == transaction.id,
          orElse: () => transaction,
        );
        
        final isIncome = currentTransaction.type == TransactionType.income;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8FAFF),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFFF5252), size: 20),
                        onPressed: () => _showDeleteDialog(context),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Icon Hero Section
                      Hero(
                        tag: 'trans_icon_${currentTransaction.id}',
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: currentTransaction.category.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: currentTransaction.category.color.withOpacity(0.2), width: 2),
                          ),
                          child: Icon(currentTransaction.category.icon, color: currentTransaction.category.color, size: 48),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currentTransaction.category.name.toUpperCase(),
                        style: TextStyle(
                          color: currentTransaction.category.color, 
                          fontSize: 12, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isIncome ? '+' : '-'}${currencyFormatter.format(currentTransaction.amount)}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: isIncome ? const Color(0xFF00C853) : const Color(0xFFFF5252),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Receipt Details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DETAIL TRANSAKSI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                            const SizedBox(height: 20),
                            _buildDetailRow(context, 'Nama', currentTransaction.title, Icons.description_outlined),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.black12)),
                            _buildDetailRow(context, 'Tanggal', DateFormat('EEEE, dd MMMM yyyy').format(currentTransaction.date), Icons.calendar_today_outlined),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.black12)),
                            _buildDetailRow(context, 'Waktu', DateFormat('HH:mm').format(currentTransaction.date), Icons.access_time),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.black12)),
                            Consumer<FinancialProvider>(
                              builder: (context, finProvider, child) {
                                final asset = finProvider.assets.firstWhere(
                                  (a) => a.id == currentTransaction.assetId,
                                  orElse: () => FinancialAsset(id: '', name: 'Tunai', amount: 0, type: AssetType.cash, icon: Icons.money, color: Colors.grey),
                                );
                                return _buildDetailRow(context, 'Sumber Dana', asset.name, Icons.account_balance_wallet_outlined);
                              },
                            ),
                            if (currentTransaction.note != null && currentTransaction.note!.isNotEmpty) ...[
                              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.black12)),
                              _buildDetailRow(context, 'Catatan', currentTransaction.note!, Icons.notes),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Image Section
                      if (currentTransaction.imagePath != null && currentTransaction.imagePath!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('BUKTI TRANSAKSI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                                const Spacer(),
                                Text('Ketuk untuk zoom', style: TextStyle(fontSize: 10, color: Colors.grey.withOpacity(0.6))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: InteractiveViewer(
                                  minScale: 1.0,
                                  maxScale: 4.0,
                                  child: Image.file(
                                    File(currentTransaction.imagePath!),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _shareTransaction(context, currentTransaction),
            backgroundColor: const Color(0xFF1E60FE),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Bagikan Struk', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Transaksi?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Data ini akan dihapus permanen. Kamu yakin gess?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600))
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(transaction.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from view screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252), 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Hapus Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
