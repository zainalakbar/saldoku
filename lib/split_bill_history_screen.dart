import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'logic/financial_provider.dart';
import 'logic/financial_models.dart';
import 'split_bill_success_screen.dart';

class SplitBillHistoryScreen extends StatelessWidget {
  const SplitBillHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D1F) : const Color(0xFFF2F5FB),
      appBar: AppBar(
        title: const Text('Riwayat Patungan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0D1C44),
      ),
      body: Consumer<FinancialProvider>(
        builder: (context, provider, child) {
          final history = provider.splitBillHistory;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('Belum ada riwayat patungan.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      'Geser kartu ke kiri untuk menghapus riwayat',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
              final h = history[index];
              return Dismissible(
                key: Key(h.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (direction) {
                  provider.deleteSplitBillHistory(h.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Riwayat "${h.title}" dihapus')),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E60FE).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF1E60FE)),
                    ),
                    title: Text(h.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(h.date),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormatter.format(h.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E60FE)),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SplitBillSuccessScreen(
                            title: h.title,
                            totalAmount: h.totalAmount,
                            debts: h.debts,
                            allUsers: h.allUsers,
                            items: h.items,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  },
),
    );
  }
}
