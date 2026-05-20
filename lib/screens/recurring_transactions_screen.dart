import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../logic/transaction_model.dart';
import '../logic/transaction_provider.dart';

class RecurringTransactionsScreen extends StatelessWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final recurring = provider.recurringTransactions;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Rutin'),
      ),
      body: recurring.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.autorenew, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('Belum ada transaksi rutin.', style: TextStyle(color: Colors.grey.withOpacity(0.6))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recurring.length,
              itemBuilder: (context, index) {
                final rt = recurring[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: rt.category.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(rt.category.icon, color: rt.category.color),
                    ),
                    title: Text(rt.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${rt.frequency.name.toUpperCase()} • ${rt.type == TransactionType.income ? "Pemasukan" : "Pengeluaran"}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormatter.format(rt.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rt.type == TransactionType.income ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Switch(
                          value: rt.isActive,
                          onChanged: (val) {
                            final updated = RecurringTransaction(
                              id: rt.id,
                              title: rt.title,
                              amount: rt.amount,
                              type: rt.type,
                              category: rt.category,
                              frequency: rt.frequency,
                              lastProcessed: rt.lastProcessed,
                              isActive: val,
                            );
                            provider.updateRecurringTransaction(updated);
                          },
                        ),
                      ],
                    ),
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Transaksi Rutin?'),
                          content: const Text('Apakah kamu yakin ingin menghapus transaksi rutin ini?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                            TextButton(
                              onPressed: () {
                                provider.deleteRecurringTransaction(rt.id);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecurringDialog(context),
        label: const Text('Tambah Rutin'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRecurringDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    TransactionType selectedType = TransactionType.expense;
    TransactionCategory selectedCategory = AppCategories.expenseCategories.first;
    RecurringFrequency selectedFreq = RecurringFrequency.monthly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final categories = selectedType == TransactionType.expense
              ? AppCategories.expenseCategories
              : AppCategories.incomeCategories;
          if (!categories.contains(selectedCategory)) {
            selectedCategory = categories.first;
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tambah Transaksi Rutin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Tipe
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<TransactionType>(
                          title: const Text('Pengeluaran', style: TextStyle(fontSize: 14)),
                          value: TransactionType.expense,
                          groupValue: selectedType,
                          onChanged: (val) => setState(() => selectedType = val!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<TransactionType>(
                          title: const Text('Pemasukan', style: TextStyle(fontSize: 14)),
                          value: TransactionType.income,
                          groupValue: selectedType,
                          onChanged: (val) => setState(() => selectedType = val!),
                        ),
                      ),
                    ],
                  ),
                  
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Judul (Misal: Bayar Kos)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Nominal', prefixText: 'Rp '),
                  ),
                  const SizedBox(height: 16),
                  
                  // Kategori
                  DropdownButtonFormField<TransactionCategory>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, color: cat.color, size: 20),
                            const SizedBox(width: 12),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  
                  // Frekuensi
                  DropdownButtonFormField<RecurringFrequency>(
                    value: selectedFreq,
                    decoration: const InputDecoration(labelText: 'Seberapa Sering?'),
                    items: const [
                      DropdownMenuItem(value: RecurringFrequency.daily, child: Text('Setiap Hari')),
                      DropdownMenuItem(value: RecurringFrequency.weekly, child: Text('Setiap Minggu')),
                      DropdownMenuItem(value: RecurringFrequency.monthly, child: Text('Setiap Bulan')),
                      DropdownMenuItem(value: RecurringFrequency.yearly, child: Text('Setiap Tahun')),
                    ],
                    onChanged: (val) => setState(() => selectedFreq = val!),
                  ),
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                          final amount = double.tryParse(amountController.text) ?? 0.0;
                          final rt = RecurringTransaction(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text,
                            amount: amount,
                            type: selectedType,
                            category: selectedCategory,
                            frequency: selectedFreq,
                            // Set lastProcessed to null so it triggers immediately upon creation
                          );
                          Provider.of<TransactionProvider>(context, listen: false).addRecurringTransaction(rt);
                          
                          // Because it's new, let's also trigger processing immediately
                          // But to be clean, let's just let the user know they need to restart or we trigger a dummy process
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transaksi rutin berhasil ditambahkan! Bekerja otomatis mulai sekarang.')),
                          );
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
